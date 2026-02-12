# Contributing Guide - Stora Landing Page

Best practices and guidelines for working with this repository and AWS infrastructure.

---

## 🔄 Development Workflow

### Making Changes

1. **Work on feature branches**, open PR into `main`
2. **Test locally first** before opening PR
3. **Commit frequently** with clear messages
4. **Update `*.md` docs** when changing deployment/infra/workflows
5. **Merge to `main` to trigger auto-deploy** via GitHub Actions

### Typical Workflow

```bash
# 1. Create a branch
git checkout -b feat/your-change

# 2. Make your changes
vim index.html
vim css/styles.css

# 3. Test locally
python3 -m http.server 8000
# Visit http://localhost:8000

# 4. Commit changes
git add -A
git commit -m "Update hero section copy

- Changed main headline
- Updated CTA button text

Co-Authored-By: Warp <agent@warp.dev>"

# 5. Push and open PR
git push -u origin feat/your-change

# 6. Merge PR to main after checks pass
# - AI PR Review
# - Docs Sync Check
# 7. Deployment runs automatically on push to main
```

---

## 🔁 CI/CD Workflow

### Required Checks Before Merge

- `AI PR Review` (posts AI review comment on the PR)
- `Docs Sync Check` (fails if deploy/infra changes are made without `*.md` updates)

### Automatic Deploy

- Merging into `main` triggers `.github/workflows/deploy-main.yml`
- Deployment uses AWS credentials from GitHub Actions secrets
- Bucket/distribution/region are injected from GitHub Actions variables

Setup details are documented in `GITHUB-ACTIONS-SETUP.md`.

---

## 📝 Commit Message Guidelines

### Format
```
<type>: <short summary>

<optional detailed description>

Co-Authored-By: Warp <agent@warp.dev>
```

### Types
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - CSS/design changes (no functionality change)
- `refactor:` - Code restructuring
- `content:` - Content/copy updates
- `deploy:` - Deployment configuration changes

### Examples

**Good:**
```bash
git commit -m "content: Update pricing section

- Changed Starter plan price to COP 120,000
- Updated Business plan features
- Added new pricing tier comparison

Co-Authored-By: Warp <agent@warp.dev>"
```

**Bad:**
```bash
git commit -m "updates"
git commit -m "fixed stuff"
git commit -m "changes"
```

---

## 🏗️ AWS Best Practices

### Before Making Changes

#### 1. **Always Check Current State**
```bash
# Check what's deployed
aws s3 ls s3://storaapp.com/ --recursive

# Check CloudFront cache status
aws cloudfront get-distribution --id E2ONCP326U5DRW \
    --query 'Distribution.Status' --output text

# Check Lambda function
aws lambda get-function --function-name stora-contact-form \
    --region us-east-1 --query 'Configuration.LastModified'
```

#### 2. **Test Contact Form After Changes**
```bash
# Test API endpoint
curl -X POST https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{
    "nombre":"Test",
    "apellido":"User",
    "email":"test@example.com",
    "empresa":"Test Co",
    "rubro":"Tech",
    "mensaje":"Test message"
  }'

# Should return: {"success":true,"message":"Email enviado correctamente",...}
```

### Deployment Best Practices

#### ✅ DO:

1. **Use the deploy script** - It handles content types correctly
   ```bash
   ./deploy.sh
   ```

2. **Invalidate CloudFront cache** - Always done by deploy.sh
   ```bash
   aws cloudfront create-invalidation \
       --distribution-id E2ONCP326U5DRW \
       --paths "/*"
   ```

3. **Wait for invalidation** before testing
   ```bash
   # Deploy script waits automatically
   # Or check status manually:
   aws cloudfront wait invalidation-completed \
       --distribution-id E2ONCP326U5DRW \
       --id <INVALIDATION_ID>
   ```

4. **Test in incognito mode** to avoid browser cache

5. **Monitor Lambda logs** during testing
   ```bash
   aws logs tail /aws/lambda/stora-contact-form \
       --region us-east-1 --follow
   ```

#### ❌ DON'T:

1. **Don't use `aws s3 sync` directly** - Use deploy.sh instead
   - It sets correct MIME types
   - It handles cache headers properly
   - It invalidates CloudFront

2. **Don't delete AWS resources manually** without documenting
   - Update aws-config.txt if you change anything
   - Update deploy.sh if IDs change
   - Update README.md resources table

3. **Don't modify Lambda without testing**
   ```bash
   # Always test Lambda changes:
   cd lambda
   npm install
   zip -r function.zip .
   aws lambda update-function-code \
       --function-name stora-contact-form \
       --zip-file fileb://function.zip \
       --region us-east-1
   
   # Then test the API endpoint
   ```

4. **Don't forget to commit aws-config.txt** after infrastructure changes

---

## 📁 File Organization

### Where Things Go

```
web-stora/
├── index.html              # Main HTML - edit here for content changes
├── css/
│   └── styles.css         # All styles - organized by section
├── js/
│   ├── main.js            # General functionality
│   └── contact-form.js    # Form logic - don't change API endpoint
├── images/
│   ├── stora-logo.svg     # Brand assets
│   ├── favicon.svg        # Keep consistent
│   ├── icons/             # Feature icons
│   └── illustrations/     # Graphics from design
├── lambda/
│   ├── index.mjs          # Lambda function code
│   ├── package.json       # Dependencies (AWS SDK v3)
│   └── node_modules/      # Don't commit (in .gitignore)
└── *.md                   # Documentation - keep updated
```

### What NOT to Commit

Already in `.gitignore`:
- `lambda/node_modules/` - npm packages
- `lambda/function.zip` - build artifact
- `.DS_Store` - macOS files
- `*.log` - log files

---

## 🎨 Content Update Guidelines

### Updating Copy/Text

1. **Edit `index.html`** directly
2. **Keep Spanish language** (target audience)
3. **Maintain brand voice** (simple, direct, accessible)
4. **Test responsiveness** after changes

### Updating Images

1. **Export from Figma** at proper resolution
2. **Use SVG** for logos and icons
3. **Use PNG** for photos/screenshots (if needed)
4. **Optimize before uploading**:
   ```bash
   # SVG optimization (optional)
   npm install -g svgo
   svgo --multipass images/icons/*.svg
   ```

### Updating Styles

1. **Use CSS variables** defined in `:root`
   ```css
   :root {
       --color-primary: #022859;    /* Stora Blue */
       --color-secondary: #F49B39;  /* Orange */
       --color-background: #E5E9EE; /* Light Gray */
   }
   ```

2. **Follow existing patterns** for consistency
3. **Test on mobile** (responsive design)
4. **Check browser compatibility** (modern browsers)

---

## 🔐 Security Best Practices

### AWS Credentials

1. **Never commit AWS credentials** to git
2. **Use IAM roles** when possible
3. **Rotate access keys** periodically
4. **Use least-privilege principle**

### Lambda Function

1. **Validate all inputs** (already implemented)
2. **Sanitize user data** (already implemented)
3. **Rate limit API** (consider adding if needed)
4. **Monitor for abuse** via CloudWatch

### SES Email

1. **Keep SES in sandbox** if <100 emails/day
2. **Request production access** if scaling
3. **Monitor bounce rates** in SES console
4. **Keep DKIM records** updated

---

## 🧪 Testing Checklist

### Before Deploying

- [ ] Code changes tested locally
- [ ] HTML validates (no errors in console)
- [ ] CSS renders correctly on all breakpoints
- [ ] JavaScript has no console errors
- [ ] Contact form validates input
- [ ] Images load correctly
- [ ] Links work
- [ ] Committed to git

### After Deploying

- [ ] Site loads at https://storaapp.com
- [ ] Site loads at https://www.storaapp.com
- [ ] No SSL warnings
- [ ] CSS applied correctly
- [ ] Images visible
- [ ] Contact form submits
- [ ] Email received at info@storaapp.com
- [ ] Tested on mobile device
- [ ] Tested in incognito mode

---

## 🚨 Emergency Procedures

### Site is Down

1. **Check CloudFront status**
   ```bash
   aws cloudfront get-distribution --id E2ONCP326U5DRW \
       --query 'Distribution.Status'
   ```

2. **Check S3 bucket**
   ```bash
   aws s3 ls s3://storaapp.com/
   ```

3. **Check DNS**
   ```bash
   dig storaapp.com
   dig www.storaapp.com CNAME
   ```

4. **Rollback if needed** (restore from git)
   ```bash
   git log --oneline -10
   git checkout <previous-commit-hash>
   ./deploy.sh
   git checkout main
   ```

### Contact Form Not Working

1. **Check Lambda logs**
   ```bash
   aws logs tail /aws/lambda/stora-contact-form \
       --region us-east-1 --since 10m
   ```

2. **Test API directly**
   ```bash
   curl -X POST https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact \
       -H "Content-Type: application/json" \
       -d '{"nombre":"Test",...}'
   ```

3. **Check SES verification**
   ```bash
   aws ses get-identity-verification-attributes \
       --identities info@storaapp.com --region us-east-1
   ```

4. **See TROUBLESHOOTING.md** for detailed fixes

### Need to Restore Everything

1. **Clone fresh from GitHub**
   ```bash
   git clone https://github.com/garnetcsmain/web-stora.git
   cd web-stora
   ```

2. **Deploy**
   ```bash
   ./deploy.sh
   ```

3. **Verify everything works** using testing checklist

---

## 🔄 Quarterly Maintenance

Every 3 months:

### Content Review
- [ ] Review all copy for accuracy
- [ ] Update pricing if needed
- [ ] Check for broken links
- [ ] Update contact information
- [ ] Review competitive positioning

### Technical Review
- [ ] Test contact form
- [ ] Check Lambda logs for errors
- [ ] Review CloudWatch metrics
- [ ] Check SES bounce/complaint rates
- [ ] Test on new browsers/devices
- [ ] Update dependencies if needed

### AWS Review
- [ ] Review AWS costs
- [ ] Check S3 storage usage
- [ ] Review CloudFront data transfer
- [ ] Monitor Lambda invocations
- [ ] Check for AWS service updates

### Documentation Review
- [ ] Update README if needed
- [ ] Review TROUBLESHOOTING guide
- [ ] Update aws-config.txt if changed
- [ ] Check all documentation is current

---

## 📊 Monitoring

### Key Metrics to Watch

1. **CloudWatch Metrics**
   - Lambda invocations
   - Lambda errors
   - API Gateway 4xx/5xx errors
   - CloudFront cache hit ratio

2. **SES Metrics**
   - Emails sent
   - Bounce rate
   - Complaint rate

3. **S3 Metrics**
   - Storage used
   - Requests

### Setting Up Alerts (Optional)

```bash
# Create SNS topic for alerts
aws sns create-topic --name stora-website-alerts --region us-east-1

# Add email subscription
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:590447489888:stora-website-alerts \
    --protocol email \
    --notification-endpoint info@storaapp.com

# Create CloudWatch alarm for Lambda errors
aws cloudwatch put-metric-alarm \
    --alarm-name stora-lambda-errors \
    --alarm-description "Alert on Lambda function errors" \
    --metric-name Errors \
    --namespace AWS/Lambda \
    --statistic Sum \
    --period 300 \
    --threshold 5 \
    --comparison-operator GreaterThanThreshold
```

---

## 🤝 Getting Help

### Documentation Priority

1. **TROUBLESHOOTING.md** - For common issues
2. **README.md** - For overview and setup
3. **This file (CONTRIBUTING.md)** - For workflow and best practices
4. **aws-config.txt** - For AWS resource references
5. **Confluence** - For architecture details

### External Resources

- **AWS Documentation**: https://docs.aws.amazon.com/
- **CloudFront Guide**: https://docs.aws.amazon.com/cloudfront/
- **Lambda Best Practices**: https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html
- **SES Developer Guide**: https://docs.aws.amazon.com/ses/

---

## 📋 Quick Reference Commands

```bash
# Deploy site
./deploy.sh

# Test locally
python3 -m http.server 8000

# Fix content types
./fix-content-types.sh

# Check Lambda logs
aws logs tail /aws/lambda/stora-contact-form --region us-east-1 --follow

# Invalidate CloudFront
aws cloudfront create-invalidation --distribution-id E2ONCP326U5DRW --paths "/*"

# Test API
curl -X POST https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact \
  -H "Content-Type: application/json" -d '{"nombre":"Test","apellido":"User",...}'

# Check what's deployed
aws s3 ls s3://storaapp.com/ --recursive

# Git workflow
git add -A
git commit -m "Your message here

Co-Authored-By: Warp <agent@warp.dev>"
git push origin main
```

---

**Last Updated**: January 12, 2026  
**Maintainer**: Fernando Sulbaran  
**Repository**: https://github.com/garnetcsmain/web-stora
