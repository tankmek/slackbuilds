#!/bin/sh

# Print informational messages to stderr
log() {
    printf '[INFO] %s\n' "$*" >&2
}

# Portable in-place sed wrapper: works on macOS (BSD sed) and GNU sed
sedi() {
    if sed --version >/dev/null 2>&1; then
        # GNU sed
        sed -i "$@"
    else
        # BSD/macOS sed
        sed -i '' "$@"
    fi
}

# Download a file and return: "<workdir> <md5sum>" on a single line
download_and_verify() {
    URL=$1
    TMPDIR=${TMPDIR:-/tmp}

    WORKDIR=$(mktemp -d "$TMPDIR/pkgbuild_XXXXXX") || {
        log "Failed to create temporary directory."
        exit 1
    }

    TARBALL_NAME=$(basename "$URL")

    log "Downloading: $URL"
    if ! curl -fsSL -A "SlackBuildBot/1.0" -o "$WORKDIR/$TARBALL_NAME" "$URL"; then
        log "Download failed. No files were changed."
        rm -rf "$WORKDIR"
        exit 1
    fi

    # Choose an MD5 implementation (Linux: md5sum, macOS: md5)
    log "Calculating MD5..."
    if command -v md5sum >/dev/null 2>&1; then
        MD5=$(md5sum "$WORKDIR/$TARBALL_NAME" | awk '{print $1}') || {
            log "MD5 calculation failed (md5sum)."
            rm -rf "$WORKDIR"
            exit 1
        }
    elif command -v md5 >/dev/null 2>&1; then
        MD5=$(md5 -q "$WORKDIR/$TARBALL_NAME") || {
            log "MD5 calculation failed (md5)."
            rm -rf "$WORKDIR"
            exit 1
        }
    else
        log "No md5sum or md5 command found on PATH."
        rm -rf "$WORKDIR"
        exit 1
    fi

    # Single line: "<workdir> <md5>"
    printf '%s %s\n' "$WORKDIR" "$MD5"
}

# Update .info file with new VERSION, DOWNLOAD, and MD5SUM
# Only update *_x86_64 fields if they were originally non-empty.
update_info_file() {
    INFO_FILE=$1
    VERSION=$2
    URL=$3
    MD5=$4

    # Always update the generic fields
    sedi \
        -e "s/^VERSION=.*/VERSION=\"$VERSION\"/" \
        -e "s|^DOWNLOAD=.*|DOWNLOAD=\"$URL\"|" \
        -e "s/^MD5SUM=.*/MD5SUM=\"$MD5\"/" \
        "$INFO_FILE"

    # Conditionally update x86_64 fields only if they are non-empty

    # DOWNLOAD_x86_64="something"
    if grep -q '^DOWNLOAD_x86_64="[^"]\+"' "$INFO_FILE"; then
        sedi "s|^DOWNLOAD_x86_64=.*|DOWNLOAD_x86_64=\"$URL\"|" "$INFO_FILE"
    fi

    # MD5SUM_x86_64="something"
    if grep -q '^MD5SUM_x86_64="[^"]\+"' "$INFO_FILE"; then
        sedi "s/^MD5SUM_x86_64=.*/MD5SUM_x86_64=\"$MD5\"/" "$INFO_FILE"
    fi
}

# Update the fallback VERSION line in the SlackBuild
update_build_file() {
    BUILD_FILE=$1
    VERSION=$2

    sedi "s/^VERSION=.*/VERSION=\${VERSION:-$VERSION}/" "$BUILD_FILE"
}

# Create <pkg>.tar.gz from the working directory, including all contents
create_archive() {
    PKG=$1
    WORKDIR=$2
    OUTFILE="${PKG}.tar.gz"

    tar -czf "$OUTFILE" -C "$WORKDIR" .

    log "Created metadata archive: $OUTFILE"
}

