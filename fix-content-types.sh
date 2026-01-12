#!/bin/bash
# Fix S3 file content types for proper rendering

BUCKET_NAME="storaapp.com"
DISTRIBUTION_ID="E2ONCP326U5DRW"

echo "🔧 Fixing S3 file content types..."

# Fix CSS files
echo "Fixing CSS files..."
aws s3 cp s3://$BUCKET_NAME/css/ s3://$BUCKET_NAME/css/ \
    --recursive \
    --exclude "*" \
    --include "*.css" \
    --content-type "text/css" \
    --metadata-directive REPLACE \
    --cache-control "public, max-age=31536000"

# Fix JavaScript files
echo "Fixing JavaScript files..."
aws s3 cp s3://$BUCKET_NAME/js/ s3://$BUCKET_NAME/js/ \
    --recursive \
    --exclude "*" \
    --include "*.js" \
    --content-type "application/javascript" \
    --metadata-directive REPLACE \
    --cache-control "public, max-age=31536000"

# Fix SVG images
echo "Fixing SVG images..."
aws s3 cp s3://$BUCKET_NAME/images/ s3://$BUCKET_NAME/images/ \
    --recursive \
    --exclude "*" \
    --include "*.svg" \
    --content-type "image/svg+xml" \
    --metadata-directive REPLACE \
    --cache-control "public, max-age=31536000"

# Fix PNG images
echo "Fixing PNG images..."
aws s3 cp s3://$BUCKET_NAME/images/ s3://$BUCKET_NAME/images/ \
    --recursive \
    --exclude "*" \
    --include "*.png" \
    --content-type "image/png" \
    --metadata-directive REPLACE \
    --cache-control "public, max-age=31536000"

# Fix HTML files
echo "Fixing HTML files..."
aws s3 cp s3://$BUCKET_NAME/index.html s3://$BUCKET_NAME/index.html \
    --content-type "text/html; charset=utf-8" \
    --metadata-directive REPLACE \
    --cache-control "public, max-age=300"

echo "✅ Content types fixed!"

# Invalidate CloudFront cache
echo "🔄 Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

echo "✅ CloudFront invalidation created: $INVALIDATION_ID"
echo ""
echo "⏱️  Cache invalidation will complete in 1-2 minutes"
echo "🌐 Test site at: https://storaapp.com/"
