# Stora Landing Page

Official landing page for Stora Warehouse Management System (WMS).

🌐 **LIVE**: https://storaapp.com | https://www.storaapp.com

## 🚀 Overview

Static HTML/CSS/JavaScript landing page showcasing Stora's WMS solution. Designed for simplicity, performance, and easy quarterly updates.

- **Domain**: storaapp.com
- **Hosting**: AWS S3 + CloudFront
- **Tech Stack**: Static HTML5, CSS3, Vanilla JavaScript
- **Design**: Based on Figma design (Node ID: 152:169)
- **Status**: ✅ Live and fully operational (deployed January 12, 2026)

## 📁 Project Structure

```
web-stora/
├── index.html              # Main landing page
├── css/
│   └── styles.css         # Main stylesheet with design tokens
├── js/
│   ├── main.js            # General site functionality
│   └── contact-form.js    # Contact form handler
├── images/
│   ├── stora-logo.svg     # Main logo (needs to be added)
│   ├── favicon.svg        # Favicon (needs to be added)
│   ├── icons/             # Feature icons (needs to be added)
│   └── illustrations/     # Graphics from Figma (needs to be added)
├── fonts/                 # Custom fonts (if needed)
├── deploy.sh             # Deployment script
└── README.md             # This file
```

## ⚙️ Setup

### Prerequisites

- AWS CLI installed and configured ✅
- S3 bucket: `storaapp.com` ✅
- CloudFront distribution configured ✅
- AWS SES configured for contact form emails ✅

### AWS Resources (Already Configured)

| Resource | Value |
|----------|-------|
| S3 Bucket | storaapp.com |
| CloudFront Distribution | E2ONCP326U5DRW |
| CloudFront URL | https://d1t6nfcjotkyin.cloudfront.net |
| Lambda Function | stora-contact-form |
| API Gateway | xmr2xk8ksc |
| SES Email | info@storaapp.com (verified) |
| Region | us-east-1 |

### Project Setup (Already Complete)

✅ All images downloaded from Figma and deployed  
✅ Deployment script configured with CloudFront distribution  
✅ Contact form configured with API Gateway endpoint  
✅ DNS records configured in Porkbun  
✅ SSL certificate issued and active

4. **Test Locally** (Optional)
   
   ```bash
   cd /Users/fsulbaran/Dev/stora/web-stora
   python3 -m http.server 8000
   # Visit http://localhost:8000
   ```

## 🚢 Deployment

### Deploy to Production

```bash
./deploy.sh
```

This will:
1. Sync all files to S3 bucket
2. Set appropriate cache headers and content types (CSS, JS, SVG, PNG)
3. Invalidate CloudFront cache
4. Wait for invalidation to complete
5. Show deployment status

**Note:** The deploy script automatically sets correct MIME types for all file types to ensure proper rendering.

### Manual Deployment

If you prefer manual deployment:

```bash
aws s3 sync . s3://storaapp.com --delete \
    --exclude ".git/*" \
    --exclude "deploy.sh" \
    --cache-control "public, max-age=3600"

aws cloudfront create-invalidation \
    --distribution-id YOUR_DISTRIBUTION_ID \
    --paths "/*"
```

## 🎨 Design System

### Colors

- **Primary (Stora Blue)**: `#022859`
- **Secondary (Orange)**: `#F49B39`
- **Background**: `#E5E9EE`
- **White**: `#FFFFFF`
- **Gray**: `#828282`

### Typography

- **Headings**: Quicksand (Bold)
- **Body**: Plus Jakarta Sans
- **Buttons**: DM Sans (Bold)

### Fonts

Loaded from Google Fonts:
- Quicksand: 400, 700
- Plus Jakarta Sans: 300, 400, 600, 700, 800 (+ italic variants)
- DM Sans: 400, 700

## 📝 Content Sections

1. **Header** - Navigation with logo and CTA
2. **Hero** - Main value proposition
3. **Problem** - Pain points (4 cards)
4. **Solution** - Key features (5 features)
5. **About** - Company description
6. **How It Works** - 4-step process
7. **Pricing** - 3 pricing tiers
8. **Contact** - Lead capture form
9. **Footer** - Copyright and contact info

## 🔧 Contact Form

The contact form submits to AWS Lambda via API Gateway. The Lambda function sends emails via SES to `info@storaapp.com`.

**Status**: ✅ Fully operational and tested

### Form Fields

- Nombre (First Name)
- Apellido (Last Name)
- Email
- Nombre Empresa (Company Name)
- Rubro (Industry)
- Mensaje (Message)

### Technical Details

- **Lambda Runtime**: Node.js 18.x with AWS SDK v3
- **API Endpoint**: https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact
- **Email Service**: AWS SES (verified and active)
- **Recipient**: info@storaapp.com
- **Features**: Input validation, sanitization, CORS enabled, HTML + plain text emails

## 📊 Analytics

Google Analytics integration is prepared but not yet active.

**To add Google Analytics:**
1. Get your GA4 tracking ID
2. Add the GA script to `index.html` in the `<head>` section
3. Deploy using `./deploy.sh`

Event tracking included:
- Form submissions (already tracked when GA is enabled)
- CTA clicks (ready to implement)
- Pricing plan clicks (ready to implement)

## 🔄 Update Schedule

**Quarterly updates** (every 3 months):
- Review content
- Update pricing if needed
- Check all links
- Test contact form
- Deploy updates

## 📚 Resources & Documentation

- **Live Site**: https://storaapp.com
- **Figma Design**: [Stora - GTM Design](https://www.figma.com/design/bfYsIuyhsACqr4g0MmggfH/Stora---GTM?node-id=152-169)
- **Confluence Doc**: [Architecture & Deployment Guide](https://garnetcs.atlassian.net/wiki/spaces/WMS/pages/144801795)
- **GitHub Repo**: https://github.com/garnetcsmain/web-stora
- **Domain Registrar**: Porkbun (storaapp.com)

### Project Documentation

- `README.md` - This file (overview and setup)
- `QUICKSTART.md` - Quick local development guide
- `TROUBLESHOOTING.md` - Complete troubleshooting guide
- `PORKBUN-DNS-SETUP.md` - DNS configuration guide
- `aws-config.txt` - AWS resources reference

## 🐛 Troubleshooting

**See `TROUBLESHOOTING.md` for comprehensive troubleshooting guide.**

Quick fixes:

### Site looks broken after deployment
```bash
./fix-content-types.sh
```

### Contact form not working
```bash
# Check Lambda logs
aws logs tail /aws/lambda/stora-contact-form --region us-east-1 --follow
```

### CSS/JS not updating
```bash
# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id E2ONCP326U5DRW --paths "/*"
```

### View all AWS resources
See `aws-config.txt` for complete resource list.

## 📞 Contact

- **Email**: contacto@storaapp.com
- **Team**: Stora WMS
- **Confluence**: WMS Space

## 📄 License

© 2025 Storaapp.com - All rights reserved
