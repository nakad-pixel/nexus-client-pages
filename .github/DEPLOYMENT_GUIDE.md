# Cloudflare Pages — Per-Client Deployment Guide

## One-Time Setup (Do This Once)

1. Log into [Cloudflare Dashboard](https://dash.cloudflare.com) → **Pages**
2. Click **Create a project** → **Connect to Git** → Select `nakad-pixel/nexus-client-pages`
3. Configure:
   - **Project name:** `nexus-CLIENT_SLUG` (e.g. `nexus-spice-garden`)
   - **Production branch:** `main`
   - **Root directory:** `clients/CLIENT_SLUG` (or `demo-restaurant` for the demo)
   - **Build command:** *(leave blank)*
   - **Build output directory:** `.`
4. Click **Save and Deploy** — Cloudflare will build and give you a `*.pages.dev` URL

## Adding a New Client (Automated via Nexus Pipeline)

The Nexus pipeline (Claude + Composio + n8n) will:
1. Generate `clients/<client-slug>/index.html`
2. Commit it to this repo via GitHub API
3. Cloudflare Pages auto-detects the change and re-deploys that project
4. The URL is logged to Google Sheets → triggers the sale pipeline

## Manual Client Add

```bash
# 1. Create client folder
mkdir -p clients/my-client

# 2. Copy nearest demo template
cp demo-restaurant/index.html clients/my-client/

# 3. Edit the HTML with client details
code clients/my-client/index.html

# 4. Commit — Cloudflare Pages picks it up automatically
git add . && git commit -m "feat: add client my-client" && git push
```

## Cloudflare Pages Projects Map

| Folder | CF Pages Project | Live URL |
|--------|-----------------|----------|
| `demo-restaurant/` | `nexus-demo-restaurant` | https://nexus-demo-restaurant.pages.dev |
| `demo-salon/` | `nexus-demo-salon` | https://nexus-demo-salon.pages.dev |
| `demo-realestate/` | `nexus-demo-realestate` | https://nexus-demo-realestate.pages.dev |
| `clients/<slug>/` | `nexus-<slug>` | https://nexus-<slug>.pages.dev |

## n8n Webhook → Google Sheets → Sale Pipeline

Once a site is deployed:
1. Append row to Google Sheet: `client_name | url | niche | deploy_date | status=new`
2. n8n watches the sheet (Google Sheets trigger)
3. On new row → fires the Nexus sale pipeline (Scout → Audit → Pitch)
4. Groq AI chatbot handles follow-up replies in the chatbot widget
