#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy.sh <client_slug> <netlify_token>
# Called by GitHub Actions deploy.yml

SLUG="$1"
NETLIFY_TOKEN="$2"
SRC_DIR="clients/${SLUG}"
SITE_NAME="nexus-${SLUG}"

echo "=== Nexus Deploy: $SLUG ==="
echo "Source: $SRC_DIR"
echo "Target site: $SITE_NAME"

# Validate
if [ ! -d "$SRC_DIR" ]; then
  echo "ERROR: directory $SRC_DIR not found"
  exit 1
fi
if [ ! -f "$SRC_DIR/index.html" ]; then
  echo "ERROR: $SRC_DIR/index.html missing"
  exit 1
fi
echo "index.html OK ($(wc -c < "$SRC_DIR/index.html") bytes)"

# Find or create Netlify site
echo "Looking up site $SITE_NAME..."
ALL_SITES=$(curl -sf \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  "https://api.netlify.com/api/v1/sites?filter=all&per_page=100")

SITE_ID=$(echo "$ALL_SITES" | python3 - "$SITE_NAME" <<'PYEOF'
import json, sys
sites = json.load(sys.stdin)
name = sys.argv[1]
match = [s["id"] for s in sites if s.get("name") == name]
print(match[0] if match else "")
PYEOF
)

if [ -z "$SITE_ID" ]; then
  echo "Site not found — creating $SITE_NAME..."
  CREATE_BODY='{"name":"'"$SITE_NAME"'"}'
  SITE_ID=$(curl -sf \
    -X POST "https://api.netlify.com/api/v1/sites" \
    -H "Authorization: Bearer $NETLIFY_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$CREATE_BODY" \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))")
  echo "Created site — ID: $SITE_ID"
else
  echo "Found site — ID: $SITE_ID"
fi

# Deploy via Netlify CLI
export NETLIFY_AUTH_TOKEN="$NETLIFY_TOKEN"
export NETLIFY_SITE_ID="$SITE_ID"

echo "Deploying via Netlify CLI..."
netlify deploy \
  --dir="$SRC_DIR" \
  --prod \
  --message="GitHub Actions deploy"

echo "=== Deploy complete ==="
echo "Live URL: https://${SITE_NAME}.netlify.app"
