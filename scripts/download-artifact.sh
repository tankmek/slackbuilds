#!/usr/bin/env bash
# Download the latest SlackBuild submission artifact for a package.
#
# Usage: download-artifact.sh <package>
#
# The workflow uploads <package>.tar.gz inside a zip artifact named
# <package>-slackbuild. `gh run download` auto-extracts the zip,
# leaving the .tar.gz ready for SBo submission.

set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <package>"
  echo
  echo "Downloads the latest submission artifact for a package."
  echo
  echo "Examples:"
  echo "  $(basename "$0") tinyproxy"
  echo
  echo "Requires: gh (GitHub CLI) — authenticate with 'gh auth login'"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

PACKAGE="$1"
ARTIFACT_NAME="${PACKAGE}-slackbuild"

# Check gh authentication
if ! gh auth status &>/dev/null; then
  echo "Error: not authenticated with GitHub CLI." >&2
  echo "Run 'gh auth login' to authenticate." >&2
  exit 1
fi

# Find the latest artifact by name via the GitHub artifacts API
echo "Finding latest artifact '${ARTIFACT_NAME}'..."
ARTIFACT_JSON=$(gh api "repos/{owner}/{repo}/actions/artifacts?name=${ARTIFACT_NAME}&per_page=1" \
  --jq '.artifacts[0] // empty')

if [[ -z "$ARTIFACT_JSON" ]]; then
  echo "Error: no artifact found named '${ARTIFACT_NAME}'." >&2
  exit 1
fi

if [[ "$(echo "$ARTIFACT_JSON" | jq -r '.expired')" == "true" ]]; then
  echo "Error: artifact '${ARTIFACT_NAME}' has expired. Re-run the workflow to generate a new one." >&2
  exit 1
fi

RUN_ID=$(echo "$ARTIFACT_JSON" | jq -r '.workflow_run.id')

echo "Downloading artifact '${ARTIFACT_NAME}' from run ${RUN_ID}..."
gh run download "$RUN_ID" -n "$ARTIFACT_NAME"

OUTPUT_FILE="${PACKAGE}.tar.gz"

if [[ ! -f "$OUTPUT_FILE" ]]; then
  echo "Error: expected ${OUTPUT_FILE} not found after download." >&2
  exit 1
fi

echo "Ready for submission: $(pwd)/${OUTPUT_FILE}"
