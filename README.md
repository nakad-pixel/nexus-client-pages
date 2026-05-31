# Nexus Web Systems — Client Pages Monorepo

> **"We don't sell websites; we sell the digital future of your brand."**

---

## 🏗️ How The Full System Works (End-to-End)

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1 — CLAUDE BUILDS & DEPLOYS                          │
│                                                             │
│  Claude generates clients/<slug>/index.html                 │
│  Claude generates clients/<slug>/netlify.toml               │
│  Claude commits → nakad-pixel/nexus-client-pages (GitHub)   │
│  Claude calls Netlify MCP → creates nexus-<slug>.netlify.app│
│  Claude appends to Google Sheet → Lead Intelligence tab     │
│    columns: Business Name, Niche, City, Rating...           │
│    + netlify_url = https://nexus-<slug>.netlify.app          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (new row with netlify_url triggers)
┌─────────────────────────────────────────────────────────────┐
│  STEP 2 — n8n SALE PIPELINE FIRES (every minute poll)      │
│                                                             │
│  Google Sheets Trigger detects new row with netlify_url     │
│  → Groq Scout Agent  — analyses business, finds pain points │
│  → Groq Audit Agent  — generates Before/After bullets       │
│  → Groq Closer Agent — writes personalized pitch email      │
│  → Gmail Draft saved (never auto-sent)                      │
│  → Pipeline Overview sheet updated with pitched status      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Repo Structure

```
nexus-client-pages/
├── shared-assets/
│   ├── nexus.css          ← Global design system
│   └── nexus.js           ← Form handler, WhatsApp fallback
├── demo-restaurant/
│   ├── index.html         ← Live: nexus-demo-restaurant.netlify.app
│   └── netlify.toml
├── demo-salon/
│   ├── index.html         ← Live: nexus-demo-salon.netlify.app
│   └── netlify.toml
├── demo-realestate/
│   ├── index.html         ← Live: nexus-demo-realestate.netlify.app
│   └── netlify.toml
└── clients/
    └── <client-slug>/     ← Auto-generated per client
        ├── index.html     ← Three.js landing page
        └── netlify.toml   ← Netlify build config
```

---

## ⚙️ One-Time Setup (Manual, Do Once)

### 1. Connect GitHub Repo to Netlify (per site)
For each `demo-*` or `clients/<slug>` folder:
- Netlify Dashboard → Add new site → Import from Git
- Repo: `nakad-pixel/nexus-client-pages`
- Base directory: `demo-restaurant` (or `clients/<slug>`)
- Build command: *(blank)*
- Publish directory: `.`
- Site name: `nexus-demo-restaurant`

> **After first setup:** Every `git push` to `main` auto-redeploys that site. Netlify detects the netlify.toml in the subfolder automatically.

### 2. n8n Workflow Credentials (Settings → Credentials)
| Credential Name | Type | Value |
|---|---|---|
| `Google Sheets OAuth` | googleSheetsTriggerOAuth2Api | OAuth with anurag2026jaiswar@gmail.com |
| `Google Sheets OAuth` | googleSheetsOAuth2Api | Same account |
| `Groq API` | httpHeaderAuth | Header: Authorization / Value: Bearer gsk_... |
| `Gmail OAuth` | gmailOAuth2 | OAuth with anurag2026jaiswar@gmail.com |

### 3. Activate the n8n Workflow
- Open: [Nexus Sale Pipeline v3](https://wolfy1223-hugging8n.hf.space/workflow/fD8eRVf6RetejZjO)
- Add all credentials above
- Toggle: **Active** (top right)

---

## 🚀 Adding a New Client (The Anurag Flow)

Say to Claude: **"Anurag, build a demo for [Business Name] in [Niche]"**

Claude will automatically:
1. ✅ Generate `clients/<client-slug>/index.html` (Three.js, brand colors, WhatsApp CTA)
2. ✅ Generate `clients/<client-slug>/netlify.toml`
3. ✅ Commit both to this repo via GitHub API
4. ✅ Create a new Netlify site via Netlify MCP → `https://nexus-<slug>.netlify.app`
5. ✅ Append a row to Google Sheet **Lead Intelligence** with the `netlify_url`
6. 🤖 n8n auto-detects the new row (polls every minute)
7. 🤖 Groq runs Scout → Audit → Closer pipeline
8. 🤖 Gmail draft saved with personalized pitch
9. 📬 You review & send from Gmail when ready

---

## 💰 Pricing Tiers (INR)

| Tier | Price | Includes |
|------|-------|----------|
| Starter Landing Page | ₹14,999 | Single page, Contact form, Mobile responsive |
| Three.js Experience | ₹34,999 | Interactive 3D, High conversion, Custom branding |
| Full Business OS | ₹74,999+ | Booking, Inventory, Premium 3D portfolio |

---

## 🔗 Key Links

| Resource | URL |
|----------|-----|
| GitHub Repo | https://github.com/nakad-pixel/nexus-client-pages |
| Google Sheet CRM | https://docs.google.com/spreadsheets/d/1rZxpKhfkzUtglL_jexKdByVN92mpkdr9KpXstrgqGF0 |
| n8n Workflow | https://wolfy1223-hugging8n.hf.space/workflow/fD8eRVf6RetejZjO |
| Demo Restaurant | https://nexus-demo-restaurant.netlify.app |
