# Stora Landing Page

Official landing page for Stora Warehouse Management System (WMS).

## 🚀 Overview

Static HTML/CSS/JavaScript landing page showcasing Stora's WMS solution. Designed for simplicity, performance, and easy quarterly updates.

- **Domain**: storaapp.com
- **Hosting**: AWS S3 + CloudFront
- **Tech Stack**: Static HTML5, CSS3, Vanilla JavaScript
- **Design**: Based on Figma design (Node ID: 152:169)

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

- AWS CLI installed and configured
- S3 bucket: `storaapp.com`
- CloudFront distribution configured
- AWS SES configured for contact form emails

### Initial Configuration

1. **Download Images from Figma**
   
   The images need to be downloaded from the Figma design. URLs are available in the Figma export (valid for 7 days):
   
   - Stora logo
   - Feature icons (5 icons)
   - Stora system illustration
   - Favicon

2. **Update Deployment Script**
   
   Edit `deploy.sh` and update:
   ```bash
   DISTRIBUTION_ID="YOUR_CLOUDFRONT_DISTRIBUTION_ID"
   ```

3. **Configure Contact Form**
   
   Edit `js/contact-form.js` and update:
   ```javascript
   const API_ENDPOINT = 'YOUR_API_GATEWAY_ENDPOINT_HERE';
   ```

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
2. Set appropriate cache headers
3. Invalidate CloudFront cache
4. Show deployment status

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

### Form Fields

- Nombre (First Name)
- Apellido (Last Name)
- Email
- Nombre Empresa (Company Name)
- Rubro (Industry)
- Mensaje (Message)

### Setup Required

1. Create Lambda function (Node.js 18.x)
2. Configure SES with verified domain and recipient
3. Create API Gateway endpoint
4. Update `API_ENDPOINT` in `contact-form.js`

## 📊 Analytics

Google Analytics integration is prepared but needs GA4 tracking code to be added to `index.html`.

Event tracking included:
- Form submissions
- CTA clicks (ready to implement)
- Pricing plan clicks (ready to implement)

## 🔄 Update Schedule

**Quarterly updates** (every 3 months):
- Review content
- Update pricing if needed
- Check all links
- Test contact form
- Deploy updates

## 📚 Resources

- **Figma Design**: [Stora - GTM Design](https://www.figma.com/design/bfYsIuyhsACqr4g0MmggfH/Stora---GTM?node-id=152-169)
- **Confluence Doc**: [Architecture & Deployment Guide](https://garnetcs.atlassian.net/wiki/spaces/WMS/pages/144801795)
- **GitHub Repo**: https://github.com/garnetcsmain/web-stora
- **Domain Registrar**: Porkbun (storaapp.com)

## 🐛 Troubleshooting

### Site not loading
- Check CloudFront distribution status
- Verify DNS records in Porkbun
- Check S3 bucket policy

### Images not displaying
- Ensure images are uploaded to `images/` folder
- Check image paths in HTML
- Verify S3 public read permissions

### Contact form not working
- Check browser console for errors
- Verify API Gateway endpoint
- Check Lambda function logs in CloudWatch
- Verify SES domain/email verification

### CSS/JS not updating
- Run CloudFront invalidation
- Check cache headers
- Clear browser cache (Cmd+Shift+R)

## 📞 Contact

- **Email**: contacto@storaapp.com
- **Team**: Stora WMS
- **Confluence**: WMS Space

## 📄 License

© 2025 Storaapp.com - All rights reserved
