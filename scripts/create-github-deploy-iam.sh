#!/usr/bin/env bash

set -euo pipefail

DEPLOY_USER="${DEPLOY_USER:-github-actions-stora-deploy}"
BUCKET_NAME="${BUCKET_NAME:-storaapp.com}"
DISTRIBUTION_ID="${DISTRIBUTION_ID:-E2ONCP326U5DRW}"
POLICY_NAME="${POLICY_NAME:-${DEPLOY_USER}-policy}"
REGION="${REGION:-us-east-1}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"
POLICY_FILE="$(mktemp)"

cleanup() {
  rm -f "${POLICY_FILE}"
}
trap cleanup EXIT

cat >"${POLICY_FILE}" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListBucket",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::${BUCKET_NAME}"
    },
    {
      "Sid": "ManageBucketObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
    },
    {
      "Sid": "CloudFrontInvalidations",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation"
      ],
      "Resource": "arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${DISTRIBUTION_ID}"
    }
  ]
}
EOF

echo "Using AWS account: ${ACCOUNT_ID}"
echo "Using region: ${REGION}"
echo "Deploy user: ${DEPLOY_USER}"
echo "Bucket: ${BUCKET_NAME}"
echo "CloudFront distribution: ${DISTRIBUTION_ID}"

aws iam create-user --user-name "${DEPLOY_USER}" >/dev/null 2>&1 || true

if aws iam get-policy --policy-arn "${POLICY_ARN}" >/dev/null 2>&1; then
  aws iam create-policy-version \
    --policy-arn "${POLICY_ARN}" \
    --policy-document "file://${POLICY_FILE}" \
    --set-as-default >/dev/null
else
  aws iam create-policy \
    --policy-name "${POLICY_NAME}" \
    --policy-document "file://${POLICY_FILE}" >/dev/null
fi

aws iam attach-user-policy \
  --user-name "${DEPLOY_USER}" \
  --policy-arn "${POLICY_ARN}" >/dev/null

echo ""
echo "Creating a fresh access key for ${DEPLOY_USER}..."
read -r ACCESS_KEY_ID SECRET_ACCESS_KEY < <(
  aws iam create-access-key \
    --user-name "${DEPLOY_USER}" \
    --query 'AccessKey.[AccessKeyId,SecretAccessKey]' \
    --output text
)

echo ""
echo "GitHub Secrets to set:"
echo "AWS_ACCESS_KEY_ID=${ACCESS_KEY_ID}"
echo "AWS_SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}"
echo ""
echo "GitHub Variables to set:"
echo "AWS_REGION=${REGION}"
echo "AWS_S3_BUCKET=${BUCKET_NAME}"
echo "AWS_CLOUDFRONT_DISTRIBUTION_ID=${DISTRIBUTION_ID}"
