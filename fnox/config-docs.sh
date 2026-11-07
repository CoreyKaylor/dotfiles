#!/usr/bin/env bash
# Keep fnox config files that live outside any git repo as 1Password documents.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$ROOT/lib.sh"

VAULT="${FNOX_OP_VAULT:-Dev}"
TAG="fnox-config"
PREFIX="fnox: ~/"

usage() {
  cat <<EOF
Usage: fnox/config-docs.sh push FILE [FILE...]
       fnox/config-docs.sh pull

push  Upload each file (must be under \$HOME) to vault $VAULT as a document
      titled "${PREFIX}<path>" and tagged $TAG. Replaces an existing one.
pull  Download every $TAG document to its path under \$HOME. Existing
      files are kept; a differing copy is written next to it as .1password.

These files hold references only, not secret values.
EOF
}

require_op() {
  command -v op >/dev/null 2>&1 || die "op is not installed (brew install --cask 1password-cli)"
  # whoami reports "not signed in" under desktop-app integration until another
  # command has authenticated, so probe the vault instead.
  op vault get "$VAULT" >/dev/null 2>&1 || die "op cannot reach vault $VAULT (signed in? CLI integration on?)"
}

push() {
  local file abs title
  for file in "$@"; do
    abs="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
    [[ -f "$abs" ]] || die "not a file: $file"
    [[ "$abs" == "$HOME"/* ]] || die "$abs is not under \$HOME"
    title="${PREFIX}${abs#"$HOME"/}"

    if op document get "$title" --vault "$VAULT" >/dev/null 2>&1; then
      op document edit "$title" "$abs" --vault "$VAULT" >/dev/null
      info "Updated $title"
    else
      op document create "$abs" --vault "$VAULT" --title "$title" --tags "$TAG" >/dev/null
      info "Created $title"
    fi
  done
}

pull() {
  local title rel dest tmp
  while IFS= read -r title; do
    [[ "$title" == "$PREFIX"* ]] || continue
    rel="${title#"$PREFIX"}"
    [[ "$rel" != *..* ]] || die "refusing path with ..: $rel"
    dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"
    tmp="$(mktemp)"
    op document get "$title" --vault "$VAULT" --out-file "$tmp" --force >/dev/null

    if [[ ! -e "$dest" ]]; then
      mv "$tmp" "$dest"
      info "Wrote ~/$rel"
    elif cmp -s "$tmp" "$dest"; then
      rm -f "$tmp"
      info "Unchanged ~/$rel"
    else
      mv "$tmp" "$dest.1password"
      info "Kept ~/$rel; 1Password copy differs, saved as ~/$rel.1password"
    fi
  done < <(op item list --vault "$VAULT" --tags "$TAG" --categories Document --format json | jq -r '.[].title')
}

case "${1:-}" in
  push) shift; (( $# )) || { usage; exit 2; }; require_op; push "$@" ;;
  pull) require_op; pull ;;
  -h|--help) usage ;;
  *) usage; exit 2 ;;
esac
