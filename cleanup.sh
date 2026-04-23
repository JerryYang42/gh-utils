#!/usr/bin/env bash
set -euo pipefail

GH_UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/bin"

unlink_if_ours() {
  local src="$GH_UTILS_DIR/$1"
  local dst="$BIN_DIR/$2"

  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
    echo "not found, skipping: $dst"
  elif [[ ! -L "$dst" ]]; then
    echo "error: $dst is not a symlink — skipping" >&2
  elif [[ "$(readlink "$dst")" != "$src" ]]; then
    echo "error: $dst points elsewhere — skipping" >&2
  else
    rm "$dst"
    echo "removed: $dst"
  fi
}

unlink_if_ours scripts/git-clone-at-tag.sh git-clone-at-tag
