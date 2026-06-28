#!/usr/bin/env bash
set -euo pipefail

SLUG="${1:?slug required}"
NETLIFY_TOKEN="${2:?token required}"

SRC_DIR="clients/${SLUG}"
SITE_NAME="nexus-${SLUG}"
LIVE_URL="https://${SITE_NAME}.netlify.app"

echo "=== Nexus Deploy: ${SLUG} ==="
echo "Source : ${SRC_DIR}"
echo "Site   : ${SITE_NAME}"

# Validate source
if [ ! -f "${SRC_DIR}/index.html" ]; then
  echo "ERROR: ${SRC_DIR}/index.html not found"
  exit 1
fi
echo "index.html OK ($(wc -c < "${SRC_DIR}/index.html") bytes)"

# Fetch all sites and extract matching ID using python with -c one-liner
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

# Deploy via Netlify CLI
export NETLIFY_AUTH_TOKEN="${NETLIFY_TOKEN}"
export NETLIFY_SITE_ID="${SITE_ID}"

echo "Deploying via Netlify CLI..."
netlify deploy \
  --dir="${SRC_DIR}" \
  --prod \
  --message="GitHub Actions deploy"

echo "=== Done — Live: ${LIVE_URL} ==="
