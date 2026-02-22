# CLAUDE.md — web-stora

> **AI agents:** This file is the source of truth for working in this repo. Read it fully before making any changes.

---

## What This Repo Does

`web-stora` is the **public marketing/landing website** for Stora WMS. It is a static HTML/CSS/JS site deployed to AWS S3 + CloudFront.

This is NOT the operational WMS application — that is `acwarehouse-web` (Angular) and `acwarehouse-mobile` (Flutter). This repo is the public-facing storefront/landing page for the Stora product.

---

## What We're Building

**Stora** is a Warehouse Management System (WMS) designed to run day-to-day warehouse operations end-to-end: receiving inventory, putting it away, tracking it, picking/packing orders, shipping, returns, and operational reporting.

### Repo Map
| Repo | Purpose |
|---|---|
| acwarehouse-back-infra-core | Master data (companies, warehouses, locations, items, users) |
| acwarehouse-back-infra-orchestrator | Cross-domain orchestration, search, configuration |
| acwarehouse-back-infra-picking | Picking routes, orders, assignments, details |
| acwarehouse-back-infra-receiving | Receiving orders, suppliers, inbound details |
| acwarehouse-back-infra-inventory | Stock levels, cycle counts, adjustments |
| acwarehouse-back-infra-transfer | Inter-warehouse/location transfers |
| acwarehouse-web | Angular admin/ops web frontend |
| acwarehouse-mobile | Flutter mobile app for warehouse floor workers |
| web-stora | Public marketing/landing website (this repo) |

---

## Key Files

| File | Purpose |
|---|---|
| `index.html` | Main landing page entry point |
| `css/` | Stylesheets |
| `js/` | JavaScript (vanilla or bundled) |
| `images/` | Site imagery and illustrations |
| `fonts/` | Web fonts |
| `lambda/` | Serverless function(s) for contact/backend features |
| `scripts/` | Build/deploy utility scripts |
| `deploy.sh` | Deployment script (S3 sync) |
| `setup-aws-infrastructure.sh` | AWS infrastructure setup |
| `fix-content-types.sh` | Fix S3 MIME types after upload |
| `aws-config.txt` | AWS deployment configuration reference |

---

## Branch Strategy

> **Note:** This repo uses `main` as the primary branch. There is no `develop` branch. All work is done on feature branches off `main` and merged back to `main`.

```
main  ←  feature branches (WMS-xxx-type/task-name)
```

---

## Dev Workflow

This is a static site. No build step is required for local development — open `index.html` directly in a browser or serve with any static file server.

```bash
# Serve locally (optional)
npx serve .          # or: python3 -m http.server 8080

# Deploy to S3
./deploy.sh          # Syncs files to S3 bucket + invalidates CloudFront cache

# Fix content types after upload (if needed)
./fix-content-types.sh
```

---

## Deployment

- **Platform:** AWS S3 (static hosting) + AWS CloudFront (CDN)
- **Deploy:** `./deploy.sh` — syncs to S3, then invalidates CloudFront distribution
- **DNS:** Configured via Porkbun (see `PORKBUN-DNS-SETUP.md`)
- **GitHub Actions:** See `GITHUB-ACTIONS-SETUP.md`

---

## PR Review Checklist

Before approving any PR in this repo, verify:

- [ ] `index.html` is valid HTML (no broken tags, correct meta tags)
- [ ] Images are optimized (not overly large PNGs/JPGs)
- [ ] SVG illustrations use correct Stora brand mark (`images/illustrations/stora-mark.svg`)
- [ ] No broken links
- [ ] `deploy.sh` still points to correct S3 bucket
- [ ] Content-type fix script (`fix-content-types.sh`) has been run if new file types added
- [ ] Mobile responsive layout checked

---

## VibeCoding Best Practices

### Branch Naming
Format: `WMS-<ticketNumber>-<type>/<kebab-case-task-name>`
Types: `feature` | `fix` | `bug` | `chore`
Examples:
```
WMS-123-feature/add-pricing-section
WMS-456-fix/mobile-responsive-header
WMS-789-chore/update-brand-logo
```

### Git Workflow
- NEVER commit directly to `main`
- ALWAYS branch off `main` (no develop branch in this repo)
- Squash commits before opening a PR (`git rebase -i origin/main`)
- PRs must be peer-reviewed — no self-merges
- Merge strategy: Squash & Merge into `main`

### Commit Messages
Format: `<type>(<scope>): <short description>`
Example: `feat(landing): add feature comparison table`

### PR Requirements
- Link Jira ticket in PR title if applicable: `[WMS-123] Add pricing section`
- All CI checks must pass before merge
- At least 1 approval required

---

## After Every Commit

| File | What to update |
|---|---|
| `CLAUDE.md` | New deployment steps, scripts, or infrastructure changes |
| `WARP.md` | Runbook: deployment commands, DNS config, troubleshooting |
