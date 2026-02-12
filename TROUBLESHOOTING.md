# Troubleshooting Guide - Stora Landing Page

## Issues Fixed (January 12, 2026)

### 🐛 Issue 1: Contact Form Not Working
**Problem:** Form submission was returning error: "Hubo un error al enviar el formulario"

**Root Cause:** 
- Lambda function was using `aws-sdk` (v2) which is not available in Node.js 18+ runtime
- Error: `Cannot find module 'aws-sdk'`

**Solution:**
- Migrated Lambda function to AWS SDK v3 (`@aws-sdk/client-ses`)
- Created `lambda/package.json` with proper dependencies
- Updated `lambda/index.mjs` to use ES modules and modern AWS SDK
- Redeployed Lambda function with dependencies

**Files Changed:**
- `lambda/index.mjs` - New file with AWS SDK v3
- `lambda/package.json` - Dependencies configuration

**Verification:**
```bash
# Test the API endpoint
curl -X POST https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test","apellido":"User","email":"test@example.com","empresa":"Test Co","rubro":"Tech","mensaje":"Test"}'

# Should return: {"success":true,"message":"Email enviado correctamente",...}
```

---

### 🐛 Issue 2: Website Not Rendering Properly
**Problem:** Site at https://storaapp.com/ was not displaying CSS styles or images correctly

**Root Cause:** 
- S3 files were uploaded with incorrect MIME types
- CSS files: `binary/octet-stream` instead of `text/css`
- SVG files: `binary/octet-stream` instead of `image/svg+xml`
- JS files: `binary/octet-stream` instead of `application/javascript`

**Solution:**
- Created `fix-content-types.sh` script to update S3 metadata
- Updated `deploy.sh` to set correct content types on upload
- Invalidated CloudFront cache to clear old headers

**Files Changed:**
- `fix-content-types.sh` - New script to fix existing files
- `deploy.sh` - Updated to use correct MIME types

**Verification:**
```bash
# Check CSS content type
curl -I https://storaapp.com/css/styles.css | grep content-type
# Should return: content-type: text/css

# Check SVG content type
curl -I https://storaapp.com/images/stora-logo.svg | grep content-type
# Should return: content-type: image/svg+xml
```

---

## How to Deploy Future Updates

### Option 1: Full Deployment (Recommended)
```bash
cd /Users/fsulbaran/Dev/stora/web-stora
./deploy.sh
```

This will:
- Sync all files to S3 with correct content types
- Set proper cache headers
- Invalidate CloudFront cache
- Wait for cache invalidation to complete

### Option 2: Quick Deploy (Files Only)
```bash
aws s3 sync . s3://storaapp.com --delete \
    --exclude ".git/*" \
    --exclude "*.md" \
    --exclude "deploy.sh"
```

Then run:
```bash
./fix-content-types.sh
```

---

## Testing Checklist

After any deployment:

- [ ] **Homepage loads:** https://storaapp.com/
- [ ] **CSS is applied:** Check if styles are visible
- [ ] **Images load:** Logo and illustrations visible
- [ ] **Form works:** Fill out contact form and submit
- [ ] **Email received:** Check info@storaapp.com inbox
- [ ] **No console errors:** Open browser DevTools

---

## Common Issues

### Issue: "AI PR Review check failed"
**Check:**
1. GitHub secret `OPENAI_API_KEY` exists and is valid
2. Workflow file exists: `.github/workflows/ai-pr-review.yml`
3. PR is not in draft state

### Issue: "Auto deploy workflow failed on main"
**Check:**
1. GitHub secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are configured
2. GitHub variables `AWS_REGION`, `AWS_S3_BUCKET`, `AWS_CLOUDFRONT_DISTRIBUTION_ID` are configured
3. IAM deploy user still has valid active access key and required policy
4. CloudFront distribution ID and bucket values are correct

### Issue: "Docs Sync Check failed"
**Cause:**
- Deployment/infra/workflow files changed, but no `*.md` docs were updated

**Fix:**
1. Update relevant documentation (`README.md`, `CONTRIBUTING.md`, `QUICKSTART.md`, etc.)
2. Commit docs updates in the same PR

### Issue: "Site looks broken after deployment"
**Solution:**
```bash
# Fix content types
./fix-content-types.sh

# Or manually invalidate cache
aws cloudfront create-invalidation \
    --distribution-id E2ONCP326U5DRW \
    --paths "/*"
```

### Issue: "Form not working"
**Check:**
1. Lambda logs: `aws logs tail /aws/lambda/stora-contact-form --region us-east-1 --follow`
2. Test API directly: `curl -X POST https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact ...`
3. Verify SES email: `aws ses get-identity-verification-attributes --identities info@storaapp.com --region us-east-1`

### Issue: "Emails not arriving"
**Check:**
1. SES verification status (must be "Success")
2. Lambda has SES permissions
3. Check spam folder
4. View Lambda logs for errors

### Issue: "Changes not visible on site"
**Solution:**
```bash
# Clear CloudFront cache
aws cloudfront create-invalidation \
    --distribution-id E2ONCP326U5DRW \
    --paths "/*"

# Wait 1-2 minutes, then test in incognito mode
```

---

## AWS Resources Reference

| Resource | Value |
|----------|-------|
| S3 Bucket | storaapp.com |
| CloudFront ID | E2ONCP326U5DRW |
| CloudFront URL | https://d1t6nfcjotkyin.cloudfront.net |
| Domain | https://storaapp.com |
| API Endpoint | https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact |
| Lambda Function | stora-contact-form |
| SES Email | info@storaapp.com |
| Region | us-east-1 |

---

## Lambda Function Updates

If you need to update the Lambda function:

```bash
cd /Users/fsulbaran/Dev/stora/web-stora/lambda

# Install dependencies (if package.json changed)
npm install

# Package and deploy
zip -r function.zip . -x "*.git*" -x "*.DS_Store"
aws lambda update-function-code \
    --function-name stora-contact-form \
    --zip-file fileb://function.zip \
    --region us-east-1

# Test
curl -X POST https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test","apellido":"User","email":"test@example.com","empresa":"Test","rubro":"Tech","mensaje":"Test"}'
```

---

## Monitoring

### View Lambda Logs
```bash
# Real-time logs
aws logs tail /aws/lambda/stora-contact-form --region us-east-1 --follow

# Last 30 minutes
aws logs tail /aws/lambda/stora-contact-form --region us-east-1 --since 30m
```

### Check CloudFront Cache Hit Rate
```bash
aws cloudfront get-distribution --id E2ONCP326U5DRW \
    --query 'Distribution.DomainName' --output text
```

### Verify SES Email Status
```bash
aws ses get-identity-verification-attributes \
    --identities info@storaapp.com \
    --region us-east-1
```

---

## Support

If you encounter issues:

1. Check this troubleshooting guide first
2. View Lambda logs for errors
3. Test components individually (API, S3, CloudFront)
4. Check AWS service status: https://status.aws.amazon.com/

---

**Last Updated:** January 12, 2026  
**Status:** ✅ All systems operational
