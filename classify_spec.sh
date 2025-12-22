#!/bin/bash
# classify_spec.sh
# Analyzes spectral_output.json to determine Agentic Readiness level.

set -e

INPUT_FILE="spectral_output.json"
OUTPUT_ENV="readiness.env"

if ! command -v jq &> /dev/null; then
  echo "jq not found. Installing..."
  apk add --no-cache jq
fi

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "Error: ${INPUT_FILE} not found."
  # If no output file, assume critical failure or empty?
  # Let's verify if 0-byte file or missing means something else.
  # If missing, defaulting to LOW is safe.
  echo "READINESS_LEVEL=readiness_low" > "${OUTPUT_ENV}"
  exit 0
fi

# Count Errors and Warnings
# Spectral JSON format: [ { "severity": 0 (Error), ... }, { "severity": 1 (Warn), ... } ]
# Severity 0 = Error, 1 = Warning, 2 = Info, 3 = Hint

ERRORS=$(jq '[.[] | select(.severity == 0)] | length' "${INPUT_FILE}")
WARNINGS=$(jq '[.[] | select(.severity == 1)] | length' "${INPUT_FILE}")

echo "Spectral Results: ${ERRORS} Errors, ${WARNINGS} Warnings."

if [[ "${ERRORS}" -gt 0 ]]; then
  LEVEL="readiness_low"
  echo "Detected ERRORS. Classification: LOW (Passive)"
elif [[ "${WARNINGS}" -gt 0 ]]; then
  LEVEL="readiness_medium"
  echo "Detected WARNINGS (No Errors). Classification: MEDIUM (Proactive)"
else
  LEVEL="readiness_high"
  echo "Clean Spec. Classification: HIGH (Autonomous)"
fi

echo "READINESS_LEVEL=${LEVEL}" > "${OUTPUT_ENV}"
cat "${OUTPUT_ENV}"
