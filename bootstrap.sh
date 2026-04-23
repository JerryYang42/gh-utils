#!/usr/bin/env bash
set -euo pipefail

GH_UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/bin"

link() {
  local src="$GH_UTILS_DIR/$1"
  local dst="$BIN_DIR/$2"

  if [[ ! -f "$src" ]]; then
    echo "error: source not found: $src" >&2
    return 1
  fi

  # Remove stale symlink (wrong target or dangling)
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" != "$src" ]]; then
    rm "$dst"
    echo "removed stale link: $dst"
  fi

  if [[ -L "$dst" ]]; then
    echo "already linked: $dst -> $src"
  elif [[ -e "$dst" ]]; then
    echo "error: $dst exists and is not a symlink — skipping" >&2
    return 1
  else
    ln -s "$src" "$dst"
    echo "linked: $dst -> $src"
  fi
}

link scripts/git-clone-at-tag.sh git-clone-at-tag
link scripts/git-clone-this-at-tag.sh git-clone-this-at-tag
