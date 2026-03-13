#!/usr/bin/env bash
# Resolve package dependencies from pkgdefs/<package>.json
# Outputs slackpkg_deps and sbopkg_deps to $GITHUB_OUTPUT
set -euo pipefail

PKG="${1:?Usage: resolve-pkgdeps.sh <package>}"
PKGDEFS="pkgdefs/${PKG}.json"

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not found" >&2
  exit 1
fi

if [ ! -f "$PKGDEFS" ]; then
  echo "No pkgdefs found for ${PKG}, no extra dependencies"
  echo "slackpkg_deps=" >> "$GITHUB_OUTPUT"
  echo "sbopkg_deps=" >> "$GITHUB_OUTPUT"
  exit 0
fi

SLACKPKG_DEPS=$(jq -r '.slackpkg_deps // [] | join(" ")' "$PKGDEFS")
SBOPKG_DEPS=$(jq -r '.sbopkg_deps // [] | join(" ")' "$PKGDEFS")

echo "slackpkg_deps=$SLACKPKG_DEPS" >> "$GITHUB_OUTPUT"
echo "sbopkg_deps=$SBOPKG_DEPS" >> "$GITHUB_OUTPUT"
echo "Resolved slackpkg_deps: $SLACKPKG_DEPS"
echo "Resolved sbopkg_deps: $SBOPKG_DEPS"
