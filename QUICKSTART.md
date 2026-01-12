# Stora Landing Page - Quick Start Guide

Complete guide to get your landing page live at https://storaapp.com

## 📋 Prerequisites

- ✅ AWS account with admin access
- ✅ AWS CLI installed and configured
- ✅ Domain storaapp.com registered at Porkbun
- ✅ Access to info@storaapp.com inbox

## 🚀 Deployment Steps

### Step 1: Refresh AWS Credentials

```bash
# If your AWS credentials are expired, refresh them
aws configure
# Or use AWS SSO:
aws sso login
```

### Step 2: Run AWS Infrastructure Setup

This script will create everything you need:

```bash
cd /Users/fsulbaran/Dev/stora/web-stora
./setup-aws-infrastructure.sh
```

**What it creates:**
- ✅ S3 bucket (`storaapp.com`)
- ✅ SSL certificate via ACM
- ✅ CloudFront distribution
- ✅ SES email configuration
- ✅ Lambda function for contact form
- ✅ API Gateway endpoint

**⏱ Estimated time:** 15-20 minutes (including waiting for SSL validation)

### Step 3: Configure DNS in Porkbun

The setup script will provide you with DNS records to add. You'll need to add:

#### For SSL Certificate Validation:
```
Type: CNAME
Name: _xxxxx.storaapp.com
Value: _xxxxx.acm-validations.aws.
```

#### For Website:
```
Type: CNAME
Name: @
Value: xxxxx.cloudfront.net

Type: CNAME  
Name: www
Value: xxxxx.cloudfront.net
```

#### For SES Email (optional, for production):
```
Type: TXT
Name: _amazonses.storaapp.com
Value: [provided by AWS]

Type: CNAME (DKIM)
Name: [provided by AWS]
Value: [provided by AWS]
```

### Step 4: Verify SES Email

1. Check inbox for `info@storaapp.com`
2. Click the verification link from AWS
3. Confirm email is verified:
   ```bash
   aws ses get-identity-verification-attributes --identities info@storaapp.com
   ```

### Step 5: Update Configuration Files

The setup script creates `aws-config.txt` with all your values. Use them to update:

#### Update `deploy.sh`:
```bash
# Line 27
DISTRIBUTION_ID="YOUR_ACTUAL_DISTRIBUTION_ID"
```

#### Update `js/contact-form.js`:
```bash
# Line 10
const API_ENDPOINT = 'YOUR_ACTUAL_API_ENDPOINT';
```

### Step 6: Deploy to Production

```bash
./deploy.sh
```

This will:
1. Sync all files to S3
2. Set proper cache headers
3. Invalidate CloudFront cache
4. Show deployment status

### Step 7: Verify Everything Works

1. **Visit the site**: https://storaapp.com
2. **Test the contact form**: Fill it out and submit
3. **Check email**: Verify you received the test submission
4. **Test on mobile**: Check responsive design
5. **Check HTTPS**: Ensure SSL certificate is working

## 🧪 Testing Locally (Before Deployment)

```bash
cd /Users/fsulbaran/Dev/stora/web-stora
python3 -m http.server 8000
```

Visit: http://localhost:8000

**Note:** Contact form won't work locally (needs API endpoint), but you can test everything else.

## 🔧 Manual Steps (Alternative to setup-aws-infrastructure.sh)

If you prefer to set up manually or the script fails:

### 1. Create S3 Bucket
```bash
aws s3 mb s3://storaapp.com --region us-east-1
aws s3 website s3://storaapp.com --index-document index.html
```

### 2. Request SSL Certificate
```bash
aws acm request-certificate \
  --domain-name storaapp.com \
  --subject-alternative-names www.storaapp.com \
  --validation-method DNS \
  --region us-east-1
```

### 3. Create CloudFront Distribution
Use AWS Console or CLI with the configuration in `setup-aws-infrastructure.sh`

### 4. Configure SES
```bash
aws ses verify-domain-identity --domain storaapp.com --region us-east-1
aws ses verify-email-identity --email-address info@storaapp.com --region us-east-1
```

### 5. Create Lambda Function
See the Lambda code in `setup-aws-infrastructure.sh` (lines 267-351)

### 6. Create API Gateway
Follow the API Gateway setup in `setup-aws-infrastructure.sh` (lines 419-526)

## 📊 Cost Estimate

**Monthly costs** (for <100 visits/day):

| Service | Cost |
|---------|------|
| S3 | ~$0.10 |
| CloudFront | FREE (within 50GB tier) |
| ACM | FREE |
| SES | FREE (<62k emails) |
| Lambda | FREE (<1M requests) |
| API Gateway | FREE (<1M requests) |
| **Total** | **~$0.11/month** |

## 🐛 Troubleshooting

### AWS Credentials Expired
```bash
aws configure
# Enter new credentials
```

### SSL Certificate Not Validating
- Check DNS records in Porkbun
- Wait 5-30 minutes for propagation
- Verify with: `dig _xxxxx.storaapp.com CNAME`

### Site Not Loading
- Check CloudFront distribution is "Deployed"
- Verify DNS records point to CloudFront domain
- Clear browser cache
- Wait for DNS propagation (up to 48 hours)

### Contact Form Not Working
- Check Lambda logs in CloudWatch
- Verify SES email is verified
- Test API endpoint directly with curl
- Check browser console for errors

### Images Not Showing
- All images are already downloaded in `images/` folder
- If missing, check `images/IMAGES_NEEDED.md`

## 📝 Post-Deployment Checklist

- [ ] Site loads at https://storaapp.com
- [ ] Site loads at https://www.storaapp.com
- [ ] SSL certificate is valid (no browser warnings)
- [ ] Contact form works and sends emails
- [ ] All images display correctly
- [ ] Site is responsive on mobile
- [ ] Navigation links work
- [ ] Google Analytics added (if desired)

## 🔄 Future Updates

To update the site (quarterly or as needed):

1. Make changes to HTML/CSS/JS files
2. Test locally: `python3 -m http.server 8000`
3. Deploy: `./deploy.sh`
4. Wait 2-3 minutes for CloudFront invalidation
5. Verify changes live

## 📞 Support

- **Confluence**: [Architecture Guide](https://garnetcs.atlassian.net/wiki/spaces/WMS/pages/144801795)
- **GitHub**: https://github.com/garnetcsmain/web-stora
- **Email**: contacto@storaapp.com

---

**Last Updated:** January 10, 2026  
**Status:** Ready for deployment ✅
