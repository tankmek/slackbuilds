#!/usr/bin/env bash
# Download the latest SlackBuild submission artifact for a package.
#
# Usage: download-artifact.sh <package>
#
# The workflow uploads <package>.tar.gz inside a zip artifact named
# <package>-slackbuild. `gh run download` auto-extracts the zip,
# leaving the .tar.gz ready for SBo submission.

set -euo pipefail

WORKFLOW_NAME="SlackBuild Update Pipeline"

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

# Find the latest successful workflow run
echo "Finding latest successful '${WORKFLOW_NAME}' run for ${PACKAGE}..."
RUN_ID=$(gh run list \
  --workflow "${WORKFLOW_NAME}" \
  --status success \
  --json databaseId,headBranch \
  --jq ".[] | select(.headBranch | startswith(\"update/${PACKAGE}-\")) | .databaseId" \
  | head -n1)

if [[ -z "$RUN_ID" ]]; then
  echo "Error: no successful run found for package '${PACKAGE}'." >&2
  exit 1
fi

echo "Downloading artifact '${ARTIFACT_NAME}' from run ${RUN_ID}..."
gh run download "$RUN_ID" -n "$ARTIFACT_NAME"

OUTPUT_FILE="${PACKAGE}.tar.gz"

if [[ ! -f "$OUTPUT_FILE" ]]; then
  echo "Error: expected ${OUTPUT_FILE} not found after download." >&2
  exit 1
fi

echo "Ready for submission: $(pwd)/${OUTPUT_FILE}"
