#!/bin/bash

# deploy.sh
# Triggers the Cloud Build pipeline to lint, register, and deploy the API.
# Usage: ./deploy.sh [legacy|agentic]

set -e

# Load environment variables
if [[ -f .env ]]; then
  source .env
else
  echo "Error: .env file not found. Please copy .env.local to .env and fill in your details."
  exit 1
fi

# Default to Agentic spec
SPEC_FILE="agentic/openapi.yaml"

# Check for "legacy" argument
if [[ "$1" == "legacy" ]]; then
  echo "🚀 Deploying Legacy (Human-Centric) Spec..."
  echo "⚠️  Expect this build to FAIL due to linter errors."
  SPEC_FILE="human-centric/openapi.yaml"
else
  echo "🚀 Deploying Agentic Spec..."
fi

echo "Submitting build for spec: ${SPEC_FILE}"

gcloud builds submit --config cloudbuild.yaml \
  --substitutions="_PROJECT_ID=${PROJECT_ID},_APIGEE_ORG=${APIGEE_ORG},_APIGEE_ENV=${APIGEE_ENV},_API_HUB_REGION=${API_HUB_REGION},_SPEC_FILE=${SPEC_FILE}"
