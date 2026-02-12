# GitHub Actions Setup - Auto Deploy + AI PR Review

This guide configures:

1. AI pull request review comments before merge.
2. Automatic deploy to AWS when code is merged into `main`.
3. Docs sync enforcement for deployment/infrastructure changes.

## Workflows Added

- `.github/workflows/ai-pr-review.yml`
- `.github/workflows/deploy-main.yml`
- `.github/workflows/docs-sync-check.yml`

## Required GitHub Repository Settings

### GitHub Secrets

Add these in **Settings > Secrets and variables > Actions > Secrets**:

- `OPENAI_API_KEY`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### GitHub Variables

Add these in **Settings > Secrets and variables > Actions > Variables**:

- `AWS_REGION` = `us-east-1`
- `AWS_S3_BUCKET` = `storaapp.com`
- `AWS_CLOUDFRONT_DISTRIBUTION_ID` = `E2ONCP326U5DRW`

## Create AWS Deploy Service Account (IAM User)

### Option A: Use the helper script (recommended)

```bash
chmod +x ./scripts/create-github-deploy-iam.sh
./scripts/create-github-deploy-iam.sh
```

This prints the exact secret/variable values to put in GitHub.

### Option B: Manual commands

Run these commands with AWS admin credentials:

```bash
export AWS_REGION="us-east-1"
export BUCKET_NAME="storaapp.com"
export DISTRIBUTION_ID="E2ONCP326U5DRW"
export DEPLOY_USER="github-actions-stora-deploy"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export POLICY_NAME="${DEPLOY_USER}-policy"
export POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"
```

Create least-privilege policy document:

```bash
cat >/tmp/${POLICY_NAME}.json <<EOF
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
```

Create IAM user + policy and attach:

```bash
aws iam create-user --user-name "${DEPLOY_USER}" || true
aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document "file:///tmp/${POLICY_NAME}.json" || true
aws iam attach-user-policy --user-name "${DEPLOY_USER}" --policy-arn "${POLICY_ARN}"
```

Create access key for GitHub Actions:

```bash
aws iam create-access-key --user-name "${DEPLOY_USER}"
```

Copy values from output:

- `AccessKeyId` -> GitHub secret `AWS_ACCESS_KEY_ID`
- `SecretAccessKey` -> GitHub secret `AWS_SECRET_ACCESS_KEY`

## Optional: Configure GitHub Secrets/Variables via CLI

Authenticate GitHub CLI first:

```bash
gh auth login
```

Then set values:

```bash
gh secret set OPENAI_API_KEY --body "<your-openai-api-key>"
gh secret set AWS_ACCESS_KEY_ID --body "<access-key-id>"
gh secret set AWS_SECRET_ACCESS_KEY --body "<secret-access-key>"

gh variable set AWS_REGION --body "us-east-1"
gh variable set AWS_S3_BUCKET --body "storaapp.com"
gh variable set AWS_CLOUDFRONT_DISTRIBUTION_ID --body "E2ONCP326U5DRW"
```

## Branch Protection (Required for Pre-Merge AI Review)

In **Settings > Branches > Branch protection rules** for `main`:

- Enable `Require a pull request before merging`.
- Enable `Require status checks to pass before merging`.
- Select checks:
  - `AI PR Review / review`
  - `Docs Sync Check / docs-sync`

This enforces AI review execution and docs sync checks before merge.

## Notes

- Deployment is triggered on `push` to `main`.
- `deploy.sh` now supports env overrides (`BUCKET`, `DISTRIBUTION_ID`, `REGION`) for CI.
- Rotate IAM access keys periodically and remove old keys after rotation.
