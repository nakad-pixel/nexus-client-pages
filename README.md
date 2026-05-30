# Nexus Web Systems — Client Pages Monorepo

> **"We don't sell websites; we sell the digital future of your brand."**

## 🗂️ Structure

```
nexus-client-pages/
├── shared-assets/          ← Global CSS, JS utilities, branding tokens
│   ├── nexus.css           ← Design system (colors, typography, spacing)
│   ├── nexus.js            ← Shared utilities (analytics, form handlers)
│   └── og-default.png      ← Default Open Graph image placeholder
├── _deploy/                ← Cloudflare Pages wrangler configs per client
│   └── template.toml       ← Copy & rename per client deployment
├── demo-restaurant/        ← Demo: Restaurant (Three.js experience)
│   └── index.html
├── demo-salon/             ← Demo: Salon/Spa (Starter landing page)
│   └── index.html
└── demo-realestate/        ← Demo: Real Estate (Full Business OS)
    └── index.html
```

## 🚀 How to Add a New Client Site

1. **Create folder:** `mkdir clients/<client-slug>/`
2. **Add `index.html`** — use any shared assets via relative path `../../shared-assets/`
3. **Commit to `main`** — Cloudflare Pages auto-deploys that subfolder
4. **Configure Cloudflare Pages** — point root dir to `clients/<client-slug>/`
5. **Log it in the Google Sheet** — triggers the n8n sale pipeline automatically

## 🔗 Deployment Architecture

```
GitHub Push → Cloudflare Pages Build Hook
     ↓
Each client = its own Cloudflare Pages project
     ↓
URL: https://<client-slug>.pages.dev  (or custom domain)
     ↓
Google Sheets log → n8n Webhook → Sale Pipeline (Scout → Audit → Prototype → Pitch)
```

## 💰 Pricing Tiers (INR)

| Tier | Price | Includes |
|------|-------|----------|
| Starter Landing Page | ₹14,999 | Single page, Contact form, Mobile responsive |
| Three.js Experience | ₹34,999 | Interactive 3D, High conversion, Custom branding |
| Full Business OS | ₹74,999+ | Booking, Inventory, Premium 3D portfolio |

## 🤖 Pipeline Agents

- **Scout Agent** — Finds 3.5★+ rated Indian businesses in a niche
- **Audit Agent** — Identifies 3 technical/design flaws costing them money
- **Architect Agent** — Builds a Three.js prototype (the Gift Strategy)
- **Closer Agent** — Drafts a Gmail pitch tied to a specific pricing tier

## ⚙️ Setup

```bash
# No build step needed — pure HTML/CSS/JS
# For local preview:
npx serve .

# To add a client:
cp -r demo-restaurant clients/my-client-name
# Edit index.html, commit, push
```
