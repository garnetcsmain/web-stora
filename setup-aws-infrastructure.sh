#!/bin/bash

###############################################################################
# Stora Landing Page - AWS Infrastructure Setup
#
# This script sets up all AWS resources needed for the landing page:
# - S3 bucket for static hosting
# - CloudFront distribution with SSL
# - ACM certificate
# - SES for email
# - Lambda function for contact form
# - API Gateway
#
# Usage: ./setup-aws-infrastructure.sh
#
# Prerequisites:
# - AWS CLI installed and configured with valid credentials
# - Domain storaapp.com registered and accessible in Porkbun
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BUCKET_NAME="storaapp.com"
REGION="us-east-1"
DOMAIN="storaapp.com"
WWW_DOMAIN="www.storaapp.com"
RECIPIENT_EMAIL="info@storaapp.com"

print_header() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

print_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured or expired"
    exit 1
fi

print_success "AWS CLI configured"

###############################################################################
# 1. Create S3 Bucket
###############################################################################
print_header "Step 1: Create S3 Bucket"

if aws s3 ls s3://${BUCKET_NAME} 2>&1 | grep -q 'NoSuchBucket'; then
    print_info "Creating S3 bucket: ${BUCKET_NAME}"
    aws s3 mb s3://${BUCKET_NAME} --region ${REGION}
    print_success "S3 bucket created"
else
    print_warning "S3 bucket already exists"
fi

# Enable static website hosting
print_info "Enabling static website hosting..."
aws s3 website s3://${BUCKET_NAME} \
    --index-document index.html \
    --error-document index.html

print_success "Static website hosting enabled"

# Create bucket policy for CloudFront access
print_info "Creating bucket policy..."
cat > /tmp/bucket-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket ${BUCKET_NAME} \
    --policy file:///tmp/bucket-policy.json

rm /tmp/bucket-policy.json

print_success "Bucket policy configured"

###############################################################################
# 2. Request SSL Certificate
###############################################################################
print_header "Step 2: Request SSL Certificate"

print_info "Requesting SSL certificate for ${DOMAIN} and ${WWW_DOMAIN}..."
print_warning "This requires DNS validation in Porkbun"

CERT_ARN=$(aws acm request-certificate \
    --domain-name ${DOMAIN} \
    --subject-alternative-names ${WWW_DOMAIN} \
    --validation-method DNS \
    --region ${REGION} \
    --query 'CertificateArn' \
    --output text)

print_success "Certificate requested: ${CERT_ARN}"

echo ""
print_warning "ACTION REQUIRED:"
print_info "1. Get DNS validation records:"
echo "   aws acm describe-certificate --certificate-arn ${CERT_ARN} --region ${REGION}"
print_info "2. Add the CNAME records to your domain in Porkbun"
print_info "3. Wait for validation (can take 5-30 minutes)"
print_info "4. Check status: aws acm describe-certificate --certificate-arn ${CERT_ARN} --region ${REGION}"
echo ""

read -p "Press Enter once certificate is validated and ready to continue..."

###############################################################################
# 3. Create CloudFront Distribution
###############################################################################
print_header "Step 3: Create CloudFront Distribution"

print_info "Creating CloudFront distribution..."

# Get S3 website endpoint
S3_WEBSITE_ENDPOINT="${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"

cat > /tmp/cloudfront-config.json <<EOF
{
    "CallerReference": "stora-$(date +%s)",
    "Comment": "Stora Landing Page CDN",
    "Enabled": true,
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-${BUCKET_NAME}",
                "DomainName": "${S3_WEBSITE_ENDPOINT}",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only"
                }
            }
        ]
    },
    "DefaultRootObject": "index.html",
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-${BUCKET_NAME}",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["GET", "HEAD"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["GET", "HEAD"]
            }
        },
        "Compress": true,
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 3600,
        "MaxTTL": 86400
    },
    "ViewerCertificate": {
        "ACMCertificateArn": "${CERT_ARN}",
        "SSLSupportMethod": "sni-only",
        "MinimumProtocolVersion": "TLSv1.2_2021"
    },
    "Aliases": {
        "Quantity": 2,
        "Items": ["${DOMAIN}", "${WWW_DOMAIN}"]
    },
    "PriceClass": "PriceClass_100"
}
EOF

DISTRIBUTION_ID=$(aws cloudfront create-distribution \
    --distribution-config file:///tmp/cloudfront-config.json \
    --query 'Distribution.Id' \
    --output text)

rm /tmp/cloudfront-config.json

print_success "CloudFront distribution created: ${DISTRIBUTION_ID}"

# Get CloudFront domain name
CF_DOMAIN=$(aws cloudfront get-distribution \
    --id ${DISTRIBUTION_ID} \
    --query 'Distribution.DomainName' \
    --output text)

print_success "CloudFront domain: ${CF_DOMAIN}"

echo ""
print_warning "ACTION REQUIRED:"
print_info "Add DNS records in Porkbun:"
print_info "  A Record: ${DOMAIN} → ${CF_DOMAIN} (use ALIAS/CNAME)"
print_info "  CNAME: ${WWW_DOMAIN} → ${CF_DOMAIN}"
echo ""

###############################################################################
# 4. Configure SES
###############################################################################
print_header "Step 4: Configure AWS SES"

print_info "Verifying domain ${DOMAIN} in SES..."
aws ses verify-domain-identity --domain ${DOMAIN} --region ${REGION}

print_info "Verifying recipient email ${RECIPIENT_EMAIL}..."
aws ses verify-email-identity --email-address ${RECIPIENT_EMAIL} --region ${REGION}

print_success "SES verification requests sent"

echo ""
print_warning "ACTION REQUIRED:"
print_info "1. Check email for verification link and click it"
print_info "2. Add SES DNS records to Porkbun (for domain verification)"
print_info "3. Request production access if needed (initially in sandbox mode)"
echo ""

###############################################################################
# 5. Create Lambda Function
###############################################################################
print_header "Step 5: Create Lambda Function"

print_info "Creating Lambda function for contact form..."

# Create Lambda function code
mkdir -p /tmp/lambda
cat > /tmp/lambda/index.js <<'LAMBDA_CODE'
const AWS = require('aws-sdk');
const ses = new AWS.SES({ region: 'us-east-1' });

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    // Parse request body
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    
    const { nombre, apellido, email, empresa, rubro, mensaje } = body;
    
    // Validate required fields
    if (!nombre || !apellido || !email || !empresa || !rubro || !mensaje) {
        return {
            statusCode: 400,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message: 'Missing required fields' })
        };
    }
    
    // Email parameters
    const params = {
        Source: process.env.SENDER_EMAIL,
        Destination: {
            ToAddresses: [process.env.RECIPIENT_EMAIL]
        },
        Message: {
            Subject: {
                Data: 'Nuevo contacto desde storaapp.com',
                Charset: 'UTF-8'
            },
            Body: {
                Text: {
                    Data: `Nuevo contacto desde storaapp.com

Nombre: ${nombre} ${apellido}
Email: ${email}
Empresa: ${empresa}
Rubro: ${rubro}

Mensaje:
${mensaje}

---
Enviado desde: https://storaapp.com
Fecha: ${new Date().toISOString()}`,
                    Charset: 'UTF-8'
                }
            }
        }
    };
    
    try {
        await ses.sendEmail(params).promise();
        console.log('Email sent successfully');
        
        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message: 'Email sent successfully' })
        };
    } catch (error) {
        console.error('Error sending email:', error);
        
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message: 'Failed to send email' })
        };
    }
};
LAMBDA_CODE

# Create deployment package
cd /tmp/lambda
zip -q function.zip index.js

# Create IAM role for Lambda
print_info "Creating IAM role for Lambda..."
cat > /tmp/trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

ROLE_NAME="stora-contact-form-lambda-role"
aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document file:///tmp/trust-policy.json \
    > /dev/null 2>&1 || print_warning "Role may already exist"

# Attach policies
aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
    > /dev/null 2>&1

aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess \
    > /dev/null 2>&1

# Get account ID and construct role ARN
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

print_info "Waiting for IAM role to propagate..."
sleep 10

# Create Lambda function
FUNCTION_NAME="stora-contact-form"
aws lambda create-function \
    --function-name ${FUNCTION_NAME} \
    --runtime nodejs18.x \
    --role ${ROLE_ARN} \
    --handler index.handler \
    --zip-file fileb:///tmp/lambda/function.zip \
    --environment "Variables={RECIPIENT_EMAIL=${RECIPIENT_EMAIL},SENDER_EMAIL=${RECIPIENT_EMAIL}}" \
    --timeout 30 \
    --region ${REGION} \
    > /dev/null 2>&1 || print_warning "Function may already exist"

print_success "Lambda function created: ${FUNCTION_NAME}"

# Cleanup
rm -rf /tmp/lambda /tmp/trust-policy.json

###############################################################################
# 6. Create API Gateway
###############################################################################
print_header "Step 6: Create API Gateway"

print_info "Creating REST API..."

API_NAME="stora-contact-api"
API_ID=$(aws apigateway create-rest-api \
    --name ${API_NAME} \
    --description "Stora Contact Form API" \
    --region ${REGION} \
    --query 'id' \
    --output text)

print_success "API created: ${API_ID}"

# Get root resource ID
ROOT_ID=$(aws apigateway get-resources \
    --rest-api-id ${API_ID} \
    --region ${REGION} \
    --query 'items[0].id' \
    --output text)

# Create /contact resource
RESOURCE_ID=$(aws apigateway create-resource \
    --rest-api-id ${API_ID} \
    --parent-id ${ROOT_ID} \
    --path-part contact \
    --region ${REGION} \
    --query 'id' \
    --output text)

# Create POST method
aws apigateway put-method \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method POST \
    --authorization-type NONE \
    --region ${REGION} \
    > /dev/null

# Set up Lambda integration
LAMBDA_ARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${FUNCTION_NAME}"

aws apigateway put-integration \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations" \
    --region ${REGION} \
    > /dev/null

# Add Lambda permission for API Gateway
aws lambda add-permission \
    --function-name ${FUNCTION_NAME} \
    --statement-id apigateway-invoke \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:${REGION}:${ACCOUNT_ID}:${API_ID}/*" \
    --region ${REGION} \
    > /dev/null 2>&1 || print_warning "Permission may already exist"

# Enable CORS
aws apigateway put-method \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method OPTIONS \
    --authorization-type NONE \
    --region ${REGION} \
    > /dev/null

aws apigateway put-integration \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method OPTIONS \
    --type MOCK \
    --request-templates '{"application/json": "{\"statusCode\": 200}"}' \
    --region ${REGION} \
    > /dev/null

aws apigateway put-method-response \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method OPTIONS \
    --status-code 200 \
    --response-parameters '{"method.response.header.Access-Control-Allow-Origin":true,"method.response.header.Access-Control-Allow-Methods":true,"method.response.header.Access-Control-Allow-Headers":true}' \
    --region ${REGION} \
    > /dev/null

aws apigateway put-integration-response \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method OPTIONS \
    --status-code 200 \
    --response-parameters '{"method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'POST,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type'"'"'"}' \
    --region ${REGION} \
    > /dev/null

# Deploy API
aws apigateway create-deployment \
    --rest-api-id ${API_ID} \
    --stage-name prod \
    --region ${REGION} \
    > /dev/null

API_ENDPOINT="https://${API_ID}.execute-api.${REGION}.amazonaws.com/prod/contact"

print_success "API deployed: ${API_ENDPOINT}"

###############################################################################
# Summary
###############################################################################
print_header "Setup Complete!"

echo ""
print_success "AWS Infrastructure Summary:"
echo ""
echo "S3 Bucket: ${BUCKET_NAME}"
echo "CloudFront Distribution ID: ${DISTRIBUTION_ID}"
echo "CloudFront Domain: ${CF_DOMAIN}"
echo "ACM Certificate ARN: ${CERT_ARN}"
echo "Lambda Function: ${FUNCTION_NAME}"
echo "API Endpoint: ${API_ENDPOINT}"
echo ""

print_warning "Next Steps:"
echo ""
echo "1. Update deploy.sh:"
echo "   DISTRIBUTION_ID=\"${DISTRIBUTION_ID}\""
echo ""
echo "2. Update js/contact-form.js:"
echo "   const API_ENDPOINT = '${API_ENDPOINT}';"
echo ""
echo "3. Verify SES email (check inbox for ${RECIPIENT_EMAIL})"
echo ""
echo "4. Add DNS records in Porkbun (see above)"
echo ""
echo "5. Deploy site: ./deploy.sh"
echo ""

# Save configuration
cat > aws-config.txt <<EOF
# AWS Configuration for Stora Landing Page
# Generated: $(date)

BUCKET_NAME=${BUCKET_NAME}
REGION=${REGION}
DISTRIBUTION_ID=${DISTRIBUTION_ID}
CF_DOMAIN=${CF_DOMAIN}
CERT_ARN=${CERT_ARN}
API_ENDPOINT=${API_ENDPOINT}
LAMBDA_FUNCTION=${FUNCTION_NAME}
EOF

print_success "Configuration saved to aws-config.txt"
echo ""
