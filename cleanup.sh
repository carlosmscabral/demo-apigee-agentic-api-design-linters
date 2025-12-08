#!/bin/bash

# cleanup.sh
# Undeploys and deletes the Agentic Order API from Apigee and API Hub.

set -e

# Load environment variables if .env exists
if [ -f .env ]; then
  source .env
fi

# Check required variables
if [ -z "$PROJECT_ID" ]; then
  echo "Error: PROJECT_ID is not set."
  exit 1
fi

if [ -z "$APIGEE_ORG" ]; then
  echo "Error: APIGEE_ORG is not set."
  exit 1
fi

if [ -z "$APIGEE_ENV" ]; then
  echo "Error: APIGEE_ENV is not set."
  exit 1
fi

if [ -z "$API_HUB_REGION" ]; then
  echo "Error: API_HUB_REGION is not set."
  exit 1
fi

PROXY_NAME=${PROXY_NAME:-"agentic-order-api"}
API_ID=${API_ID:-"agentic-order-api"}

echo "Authenticating..."
TOKEN=$(gcloud auth print-access-token)

# Ensure apigeecli is installed
if ! command -v apigeecli &> /dev/null; then
    echo "Installing apigeecli..."
    curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
    export PATH=$PATH:$HOME/.apigeecli/bin
fi

delete_api_proxy() {
  local api_name=$1
  echo "Checking deployments for $api_name in $APIGEE_ENV..."
  
  # Get the deployed revision
  REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$APIGEE_ORG" --token "$TOKEN" --disable-check | jq -r ".deployments[] | select(.apiProxy==\"$api_name\") | .revision" 2>/dev/null || true)
  
  if [ -n "$REV" ] && [ "$REV" != "null" ]; then
    echo "Undeploying revision $REV of $api_name..."
    apigeecli apis undeploy --name "$api_name" --env "$APIGEE_ENV" --rev "$REV" --org "$APIGEE_ORG" --token "$TOKEN"
  else
    echo "No active deployment found for $api_name."
  fi

  echo "Deleting proxy $api_name..."
  # Delete the proxy (all revisions)
  apigeecli apis delete --name "$api_name" --org "$APIGEE_ORG" --token "$TOKEN" || echo "Proxy $api_name might already be deleted."
}

delete_api_from_hub() {
  local api_id=$1
  echo "Deleting API $api_id from API Hub..."
  apigeecli apihub apis delete --id "$api_id" \
    --force true \
    -r "$API_HUB_REGION" -o "$PROJECT_ID" -t "$TOKEN" || echo "API $api_id might already be deleted."
}

echo "================================================="
echo "Starting Cleanup"
echo "================================================="

# 1. Delete from Apigee
delete_api_proxy "$PROXY_NAME"

# 2. Delete from API Hub
delete_api_from_hub "$API_ID"

echo "================================================="
echo "Cleanup Complete"
echo "================================================="
