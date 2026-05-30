# Nexus Web Systems — Client Pages Monorepo

> **"We don't sell websites; we sell the digital future of your brand."**

## 📁 Structure

```
nexus-client-pages/
├── shared-assets/          ← Global CSS, JS, branding tokens
│   ├── nexus.css
│   ├── nexus.js
│   └── og-default.png
├── demo-restaurant/        ← Demo: Restaurant (Three.js)
│   └── index.html
├── demo-salon/             ← Demo: Salon/Spa
│   └── index.html
├── demo-realestate/        ← Demo: Real Estate
│   └── index.html
├── clients/                ← LIVE client sites (each = one Netlify site)
│   └── <client-slug>/
│       ├── index.html
│       └── netlify.toml        ← Per-client Netlify config (auto-generated)
├── .github/workflows/
│   └── notify-n8n.yml      ← On push: pings n8n webhook with changed client slug
└── README.md
```

## 🚀 Deployment Architecture

```
Claude writes client HTML → Composio commits to GitHub
         ↓
GitHub Push → GitHub Actions detects changed client folder
         ↓
Webhook POST to n8n (client_slug, repo, timestamp)
         ↓
n8n Workflow:
  1. Netlify API: Check if site exists for client_slug
  2. If NOT: Create Netlify site linked to this repo + client subfolder
  3. If YES: Trigger redeploy via build hook
  4. Wait for deployCreated event (Netlify Trigger)
  5. Log to Google Sheets: client_name | url | niche | date | status=new
  6. Groq AI Pipeline: Scout → Audit → Prototype link → Pitch
  7. Gmail: Save pitch as draft
```

## 🆕 Adding a New Client (Full Auto Flow)

Say to Claude/Anurag: **"Build a demo for [Business Name] in [Niche]"**

Claude will:
1. Generate `clients/<client-slug>/index.html` (Three.js, brand colors, contact form)
2. Generate `clients/<client-slug>/netlify.toml` (publish dir = `.`)
3. Commit both files via GitHub API (Composio)
4. GitHub Actions fires → pings n8n webhook
5. n8n creates/updates Netlify site automatically
6. Live URL: `https://<client-slug>.netlify.app`
7. Google Sheets logs the deploy
8. n8n fires Nexus sale pipeline
9. Gmail draft pitch lands in your inbox

## 💰 Pricing Tiers (INR)

| Tier | Price | Includes |
|------|-------|----------|
| Starter Landing Page | ₹14,999 | Single page, Contact form, Mobile responsive |
| Three.js Experience | ₹34,999 | Interactive 3D, High conversion, Custom branding |
| Full Business OS | ₹74,999+ | Booking, Inventory, Premium 3D portfolio |

## ⚙️ One-Time Setup

### 1. Connect Netlify to GitHub
- Log into [app.netlify.com](https://app.netlify.com)
- No manual site creation needed — n8n handles it via API
- Save your **Netlify Personal Access Token** as a GitHub Secret: `NETLIFY_AUTH_TOKEN`

### 2. Set GitHub Secrets
```
N8N_WEBHOOK_URL    → Your n8n webhook URL (from the Nexus Pipeline workflow)
NETLIFY_AUTH_TOKEN → Your Netlify PAT (Settings → Applications → Personal access tokens)
```

### 3. Google Sheet Setup
Create a sheet named **Nexus Deployments** with columns:
`client_name | netlify_url | niche | deploy_date | tier | status | pitch_sent`

### 4. n8n Workflow
Import the **Nexus Sale Pipeline** workflow. It handles everything.

## 🤖 Pipeline Agents
- **Scout Agent** — Finds 3.5★+ rated Indian businesses in niche
- **Audit Agent** — Identifies 3 technical/design flaws costing them money
- **Architect Agent** — Links to the live Netlify prototype (Gift Strategy)
- **Closer Agent** — Groq AI drafts personalized Gmail pitch
