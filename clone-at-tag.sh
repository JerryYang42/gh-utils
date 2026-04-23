#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <repo-url> <tag|branch|sha>" >&2
  echo "Example: $(basename "$0") https://github.com/cli/cli v2.0.0" >&2
  exit 1
}

[[ $# -lt 2 ]] && usage

REPO_URL="$1"
REF="$2"
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
  echo "info: reusing existing clone at $TARGET_DIR" >&2
else
  echo "info: cloning $REPO_URL into $TARGET_DIR ..." >&2
  mkdir -p "$BASE_DIR"
  git clone "$REPO_URL" "$TARGET_DIR" >&2
fi

# Fetch latest tags and refs
echo "info: fetching tags and refs ..." >&2
git -C "$TARGET_DIR" fetch --tags --force origin >&2

# Checkout the requested ref
echo "info: checking out $REF ..." >&2
if ! git -C "$TARGET_DIR" checkout "$REF" >&2; then
  echo "error: ref '$REF' not found in $REPO_URL" >&2
  exit 1
fi

# Print the path — only stdout output, safe for command substitution
echo "$TARGET_DIR"
