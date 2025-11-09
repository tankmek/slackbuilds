#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <package-name> <new-version> [--dry-run]" >&2
    exit 1
}

# --- Parse arguments ---
if (( $# < 2 || $# > 3 )); then
    usage
fi

PKG="$1"
VERSION="$2"
DRY_RUN=""

if (( $# == 3 )); then
    if [[ "$3" == "--dry-run" ]]; then
        DRY_RUN="--dry-run"
    else
        echo "Unknown option: $3" >&2
        usage
    fi
fi

CONF_JSON="pkgdefs/$PKG.json"
PKGDIR="./$PKG"
INFO_FILE="$PKGDIR/${PKG}.info"
BUILD_FILE="$PKGDIR/${PKG}.SlackBuild"

# --- Validate files exist ---
[[ -f "$CONF_JSON" ]] || { echo "Missing: $CONF_JSON" >&2; exit 1; }
[[ -f "$INFO_FILE" ]] || { echo "Missing: $INFO_FILE" >&2; exit 1; }
[[ -f "$BUILD_FILE" ]] || { echo "Missing: $BUILD_FILE" >&2; exit 1; }

# --- Check jq availability ---
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed (e.g. brew install jq)." >&2
    exit 1
fi

# --- Load shared functions ---
. ./utils.sh

WORKDIR=""
TARBALL_NAME=""

cleanup() {
    if [[ -n "${WORKDIR:-}" && -d "$WORKDIR" ]]; then
        rm -rf "$WORKDIR"
    fi
}
trap cleanup EXIT

# --- Extract current version and short-circuit if same ---
CURRENT_VERSION=$(
    awk -F= '/^VERSION=/ { gsub(/"/,"",$2); print $2; exit }' "$INFO_FILE"
)

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
    log "No update needed: current version already $VERSION."
    exit 0
fi

# --- Load template URL and generate download target ---
DOWNLOAD_FMT=$(jq -r '.download_fmt // empty' "$CONF_JSON")
if [[ -z "$DOWNLOAD_FMT" ]]; then
    echo "Error: .download_fmt not found or empty in $CONF_JSON" >&2
    exit 1
fi

URL=$(printf '%s' "$DOWNLOAD_FMT" | sed "s/%v/$VERSION/g")

# --- Download and hash tarball ---
# download_and_verify outputs: "<WORKDIR> <MD5> <TARBALL_NAME>"
read -r WORKDIR MD5 TARBALL_NAME < <(download_and_verify "$URL")

# --- Copy working files (include dotfiles, preserve attrs) ---
cp -a "$PKGDIR"/. "$WORKDIR"/

# --- Apply updates in the working directory ---
update_info_file   "$WORKDIR/${PKG}.info"       "$VERSION" "$URL" "$MD5"
update_build_file  "$WORKDIR/${PKG}.SlackBuild" "$VERSION"

# --- Dry-run: show proposed changes without modifying source tree ---
if [[ "$DRY_RUN" == "--dry-run" ]]; then
    echo "=== DRY RUN: Showing proposed changes for $PKG $VERSION ==="

    if command -v delta >/dev/null 2>&1; then
        DIFF="delta --paging=always --syntax-theme=Dracula"
    else
        DIFF="cat"
    fi

    echo "--- .info diff ---"
    diff -u "$PKGDIR/${PKG}.info" "$WORKDIR/${PKG}.info" | $DIFF || true

    echo "--- .SlackBuild diff ---"
    diff -u "$PKGDIR/${PKG}.SlackBuild" "$WORKDIR/${PKG}.SlackBuild" | $DIFF || true

    echo "Dry run complete. No files modified."
    exit 0
fi

# --- Non-dry-run: sync updated files back into the real tree ---
cp -a "$WORKDIR/${PKG}.info"       "$INFO_FILE"
cp -a "$WORKDIR/${PKG}.SlackBuild" "$BUILD_FILE"

# --- Final archive (excluding the downloaded tarball) ---
create_archive "$PKG" "$WORKDIR" "$TARBALL_NAME"

log "Update complete for $PKG -> $VERSION"

