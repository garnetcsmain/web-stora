# Images Required from Figma

The following images need to be downloaded from the Figma design and placed in this directory.

## Figma Export URLs (Valid for 7 days from January 10, 2026)

### Logo & Branding
- **Stora Logo**: `imgStoraLogo` → Save as `stora-logo.svg`
  - URL: https://www.figma.com/api/mcp/asset/599d3f61-a67b-4dcc-939f-cb4d87c5ea43
  - Location: `images/stora-logo.svg`
  - Size: 168x34px

- **Favicon**: Create from logo → Save as `favicon.svg`
  - Location: `images/favicon.svg`

### Hero Section
- **Hero Illustration**: `imgGroup` + `imgGroup1` (combined logo illustration)
  - Group 1 URL: https://www.figma.com/api/mcp/asset/ea93cbeb-7098-45bb-8691-8096d3d644ce
  - Group 2 URL: https://www.figma.com/api/mcp/asset/530d97ed-4fda-4f51-920d-ed793c890c70
  - Location: `images/illustrations/stora-logo-illustration.svg`

### Solution Section Icons (save in `images/icons/`)

1. **Warehouse Icon**: `imgRegistroRapidoDeBodegasEItems`
   - URL: https://www.figma.com/api/mcp/asset/d62fd05b-99b7-401b-bfe1-0bce784cb44f
   - Location: `images/icons/warehouse.svg`

2. **Mobile Icon**: `imgConteoFisicoDesdeElCelular`
   - URL: https://www.figma.com/api/mcp/asset/cfc8e378-26b2-43b9-95a3-2dd0d2bbbd14
   - Location: `images/icons/mobile.svg`

3. **Dashboard Icon**: `imgDashboardConDiferenciasEnTiempoReal`
   - URL: https://www.figma.com/api/mcp/asset/56c72736-192c-4ca3-8f68-ac71b8447283
   - Location: `images/icons/dashboard.svg`

4. **Alerts Icon**: `imgAlertasYVariacionesVisiblesDeInmediato`
   - URL: https://www.figma.com/api/mcp/asset/4f571f76-e35d-4812-927a-c15981fd823c
   - Location: `images/icons/alerts.svg`

5. **Users Icon**: `imgMultiusuarioYEscalable`
   - URL: https://www.figma.com/api/mcp/asset/d31ea43d-3ab0-48b6-9b70-d2678e1b2574
   - Location: `images/icons/users.svg`

### About Section Illustration
- **Stora System Illustration**: Combined groups showing system architecture
  - URLs:
    - Group 2: https://www.figma.com/api/mcp/asset/8b39074e-9f93-4a69-970c-aabeb67fd331
    - Group 3: https://www.figma.com/api/mcp/asset/7f27087b-a53d-427e-abba-be0c4e9aae7d
    - Group 4: https://www.figma.com/api/mcp/asset/c73e0f10-6cbd-4b4e-894c-f9f6075e0b7b
    - Vector: https://www.figma.com/api/mcp/asset/a2f9b5e5-e957-4f60-8868-46a00c39daef
    - Group 5: https://www.figma.com/api/mcp/asset/77b34b11-a769-478c-bc03-eb7e4de9c7b5
    - Group 6: https://www.figma.com/api/mcp/asset/a2fd6bcf-eb65-4fcd-90a9-c41386cbd024
  - Location: `images/illustrations/stora-system.svg`

## Quick Download Script

You can use curl to download these images:

```bash
#!/bin/bash

# Navigate to web-stora directory
cd /Users/fsulbaran/Dev/stora/web-stora

# Download logo
curl -o images/stora-logo.svg "https://www.figma.com/api/mcp/asset/599d3f61-a67b-4dcc-939f-cb4d87c5ea43"

# Download hero illustration (you'll need to combine these)
curl -o images/illustrations/hero-group1.svg "https://www.figma.com/api/mcp/asset/ea93cbeb-7098-45bb-8691-8096d3d644ce"
curl -o images/illustrations/hero-group2.svg "https://www.figma.com/api/mcp/asset/530d97ed-4fda-4f51-920d-ed793c890c70"

# Download icons
curl -o images/icons/warehouse.svg "https://www.figma.com/api/mcp/asset/d62fd05b-99b7-401b-bfe1-0bce784cb44f"
curl -o images/icons/mobile.svg "https://www.figma.com/api/mcp/asset/cfc8e378-26b2-43b9-95a3-2dd0d2bbbd14"
curl -o images/icons/dashboard.svg "https://www.figma.com/api/mcp/asset/56c72736-192c-4ca3-8f68-ac71b8447283"
curl -o images/icons/alerts.svg "https://www.figma.com/api/mcp/asset/4f571f76-e35d-4812-927a-c15981fd823c"
curl -o images/icons/users.svg "https://www.figma.com/api/mcp/asset/d31ea43d-3ab0-48b6-9b70-d2678e1b2574"

# Download system illustration components
curl -o images/illustrations/system-group2.svg "https://www.figma.com/api/mcp/asset/8b39074e-9f93-4a69-970c-aabeb67fd331"
curl -o images/illustrations/system-group3.svg "https://www.figma.com/api/mcp/asset/7f27087b-a53d-427e-abba-be0c4e9aae7d"
curl -o images/illustrations/system-group4.svg "https://www.figma.com/api/mcp/asset/c73e0f10-6cbd-4b4e-894c-f9f6075e0b7b"
curl -o images/illustrations/system-vector.svg "https://www.figma.com/api/mcp/asset/a2f9b5e5-e957-4f60-8868-46a00c39daef"
curl -o images/illustrations/system-group5.svg "https://www.figma.com/api/mcp/asset/77b34b11-a769-478c-bc03-eb7e4de9c7b5"
curl -o images/illustrations/system-group6.svg "https://www.figma.com/api/mcp/asset/a2fd6bcf-eb65-4fcd-90a9-c41386cbd024"

echo "✓ Images downloaded!"
echo "Note: Hero and system illustrations may need to be combined in a vector editor"
```

## Alternative: Download from Figma

1. Open the Figma design: https://www.figma.com/design/bfYsIuyhsACqr4g0MmggfH/Stora---GTM?node-id=152-169
2. Select each element
3. Right-click → "Export" or use Export panel (bottom-right)
4. Choose SVG format
5. Download and rename according to the locations above

## Important Notes

- **URLs expire after 7 days** (expires around January 17, 2026)
- If URLs expire, you'll need to export directly from Figma
- SVG format is preferred for scalability and smaller file sizes
- Some illustrations may need to be combined or edited in a vector editor
- Create favicon from the main logo (can use favicon generators online)

## After Downloading

Once all images are in place:
1. Remove or update placeholder references in HTML
2. Test locally: `python3 -m http.server 8000`
3. Verify all images load correctly
4. Deploy to S3
