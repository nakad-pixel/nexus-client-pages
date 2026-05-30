# =======================================================
# Nexus Sale Pipeline — n8n Workflow Setup Guide
# =======================================================

## What the n8n Workflow Does

1. **Trigger**: Webhook receives POST from GitHub Actions
   - Payload: { client_slug, repo, branch, commit_sha, pushed_at }

2. **Netlify Site Check**: HTTP GET to Netlify API
   - GET https://api.netlify.com/api/v1/sites?filter=all
   - Check if site named nexus-{client_slug} already exists

3a. **If site DOES NOT exist**: Create it
    - POST https://api.netlify.com/api/v1/sites
    - Link to GitHub repo, set root_dir = clients/{client_slug}
    - Returns: site_id, default_domain (*.netlify.app)

3b. **If site EXISTS**: Trigger redeploy
    - POST https://api.netlify.com/api/v1/sites/{site_id}/builds

4. **Wait / Poll**: Check deployment status (deployCreated event)
   - Poll GET https://api.netlify.com/api/v1/sites/{site_id}/deploys
   - Wait until state = 'ready'

5. **Log to Google Sheets**
   - Sheet: "Nexus Deployments"
   - Columns: client_name | netlify_url | niche | deploy_date | tier | status

6. **Groq AI Pipeline** (using your configured Groq API key)
   - Scout: Web search for business details + reviews
   - Audit: Technical/UX flaw analysis
   - Closer: Generate personalized pitch email

7. **Gmail Draft**: Save pitch as draft (never auto-sends)

## Required n8n Credentials

- **Netlify API**: Personal Access Token (netlifyApi credential)
- **Google Sheets OAuth2**: For logging deployments
- **Gmail OAuth2**: For saving pitch drafts
- **Groq**: API key (already configured in your chatbot)

## Netlify API Authentication

All Netlify API calls use:
```
Authorization: Bearer YOUR_NETLIFY_PERSONAL_ACCESS_TOKEN
```
Get token: app.netlify.com → User Settings → Applications → New access token

## Google Sheet Structure

| Column | Description |
|--------|-------------|
| client_name | Business name (from client_slug) |
| netlify_url | https://{slug}.netlify.app |
| niche | Business category (from Groq) |
| deploy_date | ISO timestamp |
| tier | Pricing tier (Starter/3JS/Full OS) |
| status | new / pitched / closed |
| pitch_sent | TRUE/FALSE |
