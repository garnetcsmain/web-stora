#!/bin/bash

###############################################################################
# Stora Landing Page - Deployment Script
# 
# This script deploys the landing page to AWS S3 and invalidates CloudFront cache
#
# Usage: ./deploy.sh
#
# Prerequisites:
# - AWS CLI installed and configured
# - S3 bucket created (storaapp.com)
# - CloudFront distribution created
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUCKET="storaapp.com"
DISTRIBUTION_ID="E2ONCP326U5DRW"
REGION="us-east-1"

# Print with color
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

# Banner
echo ""
echo "========================================="
echo "  Stora Landing Page - Deployment"
echo "========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials are not configured. Please run 'aws configure'."
    exit 1
fi

print_success "AWS CLI is configured"

# Check if CloudFront distribution ID is set
if [ "$DISTRIBUTION_ID" == "YOUR_CLOUDFRONT_DISTRIBUTION_ID" ]; then
    print_warning "CloudFront distribution ID not set. Cache invalidation will be skipped."
    SKIP_INVALIDATION=true
else
    SKIP_INVALIDATION=false
fi

# Sync files to S3
print_info "Deploying to S3 bucket: ${BUCKET}"
echo ""

aws s3 sync . s3://${BUCKET} \
    --region ${REGION} \
    --delete \
    --exclude ".git/*" \
    --exclude ".gitignore" \
    --exclude ".DS_Store" \
    --exclude "deploy.sh" \
    --exclude "README.md" \
    --exclude "*.md" \
    --cache-control "public, max-age=3600" \
    --metadata-directive REPLACE

if [ $? -eq 0 ]; then
    print_success "Files synced to S3 successfully"
else
    print_error "Failed to sync files to S3"
    exit 1
fi

# Set specific cache headers and content types for different file types
print_info "Setting cache headers and content types..."

# HTML - short cache (5 minutes)
aws s3 cp s3://${BUCKET}/index.html s3://${BUCKET}/index.html \
    --region ${REGION} \
    --cache-control "public, max-age=300" \
    --metadata-directive REPLACE \
    --content-type "text/html; charset=utf-8" \
    > /dev/null 2>&1

# CSS files - long cache (1 year)
aws s3 cp s3://${BUCKET}/css/ s3://${BUCKET}/css/ \
    --region ${REGION} \
    --recursive \
    --exclude "*" \
    --include "*.css" \
    --cache-control "public, max-age=31536000" \
    --content-type "text/css" \
    --metadata-directive REPLACE \
    > /dev/null 2>&1 || true

# JavaScript files - long cache (1 year)
aws s3 cp s3://${BUCKET}/js/ s3://${BUCKET}/js/ \
    --region ${REGION} \
    --recursive \
    --exclude "*" \
    --include "*.js" \
    --cache-control "public, max-age=31536000" \
    --content-type "application/javascript" \
    --metadata-directive REPLACE \
    > /dev/null 2>&1 || true

# SVG images - long cache (1 year)
aws s3 cp s3://${BUCKET}/images/ s3://${BUCKET}/images/ \
    --region ${REGION} \
    --recursive \
    --exclude "*" \
    --include "*.svg" \
    --cache-control "public, max-age=31536000" \
    --content-type "image/svg+xml" \
    --metadata-directive REPLACE \
    > /dev/null 2>&1 || true

# PNG images - long cache (1 year)
aws s3 cp s3://${BUCKET}/images/ s3://${BUCKET}/images/ \
    --region ${REGION} \
    --recursive \
    --exclude "*" \
    --include "*.png" \
    --cache-control "public, max-age=31536000" \
    --content-type "image/png" \
    --metadata-directive REPLACE \
    > /dev/null 2>&1 || true

print_success "Cache headers configured"

# Invalidate CloudFront cache
if [ "$SKIP_INVALIDATION" = false ]; then
    print_info "Invalidating CloudFront cache..."
    
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id ${DISTRIBUTION_ID} \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    if [ $? -eq 0 ]; then
        print_success "CloudFront invalidation created: ${INVALIDATION_ID}"
        print_info "Waiting for invalidation to complete (this may take 2-3 minutes)..."
        
        aws cloudfront wait invalidation-completed \
            --distribution-id ${DISTRIBUTION_ID} \
            --id ${INVALIDATION_ID}
        
        print_success "CloudFront cache invalidated successfully"
    else
        print_error "Failed to create CloudFront invalidation"
        exit 1
    fi
else
    print_warning "Skipping CloudFront invalidation (distribution ID not configured)"
fi

# Summary
echo ""
echo "========================================="
print_success "Deployment completed successfully!"
echo "========================================="
echo ""
print_info "Website URL: https://storaapp.com"
if [ "$SKIP_INVALIDATION" = false ]; then
    print_info "Changes will be live in 2-3 minutes"
else
    print_info "Don't forget to configure CloudFront and update DISTRIBUTION_ID in this script"
fi
echo ""
