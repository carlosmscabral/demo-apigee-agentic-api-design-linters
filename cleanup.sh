#!/bin/bash

# cleanup.sh
# Undeploys and deletes the Agentic Order API from Apigee and API Hub.

set -e

# Load environment variables if .env exists
if [[ -f .env ]]; then
  source .env
fi

# Check required variables
if [[ -z "${PROJECT_ID}" ]]; then
  echo "Error: PROJECT_ID is not set."
  exit 1
fi


if [[ -z "${API_HUB_REGION}" ]]; then
  echo "Error: API_HUB_REGION is not set."
  exit 1
fi

echo "Authenticating..."
TOKEN="$(gcloud auth print-access-token)"

# Ensure apigeecli is installed (still needed for API Hub)
if ! command -v apigeecli &> /dev/null; then
    echo "Installing apigeecli..."
    curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
    export PATH="${PATH}:${HOME}/.apigeecli/bin"
fi

delete_api_from_hub() {
  local api_id="$1"
  echo "Deleting API ${api_id} from API Hub..."
  if ! apigeecli apihub apis delete \
      --id "${api_id}" \
      --force true \
      -r "${API_HUB_REGION}" \
      -o "${PROJECT_ID}" \
      -t "${TOKEN}"; then
      echo "API ${api_id} might already be deleted."
  fi
}

echo "Starting Cleanup"
echo "================================================="

# 1. Delete from API Hub
delete_api_from_hub "${API_ID}"

echo "================================================="
echo "Cleanup Complete"
echo "================================================="
