#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: $(basename "$0") [-v|--verbose] <tag>" >&2
  echo "Run from within a git repo. Clones the current repo at the given tag to a temp folder." >&2
  echo "Example: $(basename "$0") v2.0.0" >&2
  exit 1
}

PASSTHROUGH=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) PASSTHROUGH+=("$1"); shift ;;
    -*) echo "error: unknown flag: $1" >&2; usage ;;
    *) break ;;
  esac
done

[[ $# -lt 1 ]] && usage
TAG="$1"

# Must be run from inside a git repo
if ! git rev-parse --git-dir &>/dev/null 2>&1; then
  echo "error: not inside a git repository" >&2
  exit 1
fi

# Get the remote URL of origin
REPO_URL="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$REPO_URL" ]]; then
  echo "error: no 'origin' remote found in this repo" >&2
  exit 1
fi

exec git-clone-at-tag "${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"}" "$REPO_URL" "$TAG"
