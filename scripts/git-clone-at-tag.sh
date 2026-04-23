#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [-v|--verbose] <repo-url> <tag>" >&2
  echo "Example: $(basename "$0") https://github.com/cli/cli v2.0.0" >&2
  exit 1
}

VERBOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) VERBOSE=1; shift ;;
    -*) echo "error: unknown flag: $1" >&2; usage ;;
    *) break ;;
  esac
done

[[ $# -lt 2 ]] && usage

REPO_URL="$1"
REF="$2"

info() { [[ $VERBOSE -eq 1 ]] && echo "info: $*" >&2 || true; }
BASE_DIR="/tmp/clone-at-tag"

# Extract repo name from URL (strip .git suffix and trailing slashes)
REPO_NAME="$(basename "${REPO_URL%.git}")"
if [[ -z "$REPO_NAME" ]]; then
  echo "error: could not derive repo name from URL: $REPO_URL" >&2
  exit 1
fi

TARGET_DIR="$BASE_DIR/$REPO_NAME"

# Clone if not already a valid git repo
if git -C "$TARGET_DIR" rev-parse --git-dir &>/dev/null 2>&1; then
  info "reusing existing clone at $TARGET_DIR"
else
  info "cloning $REPO_URL into $TARGET_DIR ..."
  mkdir -p "$BASE_DIR"
  if [[ $VERBOSE -eq 1 ]]; then
    git clone "$REPO_URL" "$TARGET_DIR" >&2
  else
    git clone --quiet "$REPO_URL" "$TARGET_DIR" 2>/dev/null
  fi
fi

# Fetch latest tags and refs
info "fetching tags and refs ..."
if [[ $VERBOSE -eq 1 ]]; then
  git -C "$TARGET_DIR" fetch --tags --force origin >&2
else
  git -C "$TARGET_DIR" fetch --tags --force --quiet origin 2>/dev/null
fi

# Verify the ref is a known tag
if ! git -C "$TARGET_DIR" tag --list "$REF" | grep -qx "$REF"; then
  echo "error: '$REF' is not a tag in $REPO_URL" >&2
  available="$(git -C "$TARGET_DIR" tag --sort=-version:refname | head -3)"
  if [[ -n "$available" ]]; then
    echo "available tags (latest 3):" >&2
    echo "$available" | sed 's/^/  /' >&2
  fi
  echo "" >&2
  echo "to list all tags, run:" >&2
  echo "  git -C \"$TARGET_DIR\" tag --sort=-version:refname" >&2
  exit 1
fi

# Checkout the tag
info "checking out $REF ..."
if ! git -C "$TARGET_DIR" checkout "$REF" 2>/dev/null; then
  echo "error: failed to checkout tag '$REF'" >&2
  exit 1
fi

# Print the path — only stdout output, safe for command substitution
echo "$TARGET_DIR"
