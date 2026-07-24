#!/usr/bin/env bash
set -euo pipefail

SLUG="${1:?slug required}"
NETLIFY_TOKEN="${2:?token required}"

SRC_DIR="clients/${SLUG}"
SITE_NAME="nexus-${SLUG}"
FALLBACK_URL="https://${SITE_NAME}.netlify.app"

echo "=== Nexus Deploy: ${SLUG} ==="
echo "Source : ${SRC_DIR}"
echo "Site   : ${SITE_NAME}"

# Validate source
if [ ! -f "${SRC_DIR}/index.html" ]; then
  echo "ERROR: ${SRC_DIR}/index.html not found"
  exit 1
fi
echo "index.html OK ($(wc -c < "${SRC_DIR}/index.html") bytes)"

# Fetch all sites and extract matching ID
echo "Looking up Netlify site..."
SITES_FILE=$(mktemp)
curl -sf \
  -H "Authorization: Bearer ${NETLIFY_TOKEN}" \
  "https://api.netlify.com/api/v1/sites?filter=all&per_page=100" \
  -o "${SITES_FILE}"

SITE_ID=$(python3 -c "
import json
with open('${SITES_FILE}') as f:
    sites = json.load(f)
match = [s['id'] for s in sites if s.get('name') == '${SITE_NAME}']
print(match[0] if match else '')
")
rm -f "${SITES_FILE}"

if [ -z "${SITE_ID}" ]; then
  echo "Creating new site: ${SITE_NAME}"
  RESP_FILE=$(mktemp)
  curl -sf \
    -X POST "https://api.netlify.com/api/v1/sites" \
    -H "Authorization: Bearer ${NETLIFY_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${SITE_NAME}\"}" \
    -o "${RESP_FILE}"
  SITE_ID=$(python3 -c "import json; print(json.load(open('${RESP_FILE}')).get('id',''))")
  rm -f "${RESP_FILE}"
  echo "Created — ID: ${SITE_ID}"
else
  echo "Found — ID: ${SITE_ID}"
fi

if [ -z "${SITE_ID}" ]; then
  echo "ERROR: Could not get or create Netlify site"
  exit 1
fi

# Deploy via Netlify CLI, capture the REAL deploy URL instead of guessing it
export NETLIFY_AUTH_TOKEN="${NETLIFY_TOKEN}"
export NETLIFY_SITE_ID="${SITE_ID}"

echo "Deploying via Netlify CLI..."
DEPLOY_JSON=$(mktemp)
netlify deploy \
  --dir="${SRC_DIR}" \
  --prod \
  --message="GitHub Actions deploy" \
  --json > "${DEPLOY_JSON}" || {
    echo "ERROR: netlify deploy command failed"
    cat "${DEPLOY_JSON}" || true
    exit 1
  }

REAL_URL=$(python3 -c "
import json
try:
    d = json.load(open('${DEPLOY_JSON}'))
    print(d.get('deploy_url') or d.get('url') or d.get('site_url') or '')
except Exception:
    print('')
")
rm -f "${DEPLOY_JSON}"

if [ -z "${REAL_URL}" ]; then
  echo "WARNING: could not parse deploy URL from Netlify CLI JSON output — falling back to conventional URL pattern"
  REAL_URL="${FALLBACK_URL}"
fi

# Expose to the calling GitHub Actions step
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "live_url=${REAL_URL}" >> "${GITHUB_OUTPUT}"
fi

echo "=== Done — Live: ${REAL_URL} ==="
