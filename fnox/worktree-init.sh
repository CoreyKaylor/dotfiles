#!/usr/bin/env bash
# Create a parent fnox.toml so every child directory inherits shared CLI secrets.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: fnox/worktree-init.sh <dir> [dir...]

Write a names-only fnox.toml at each work-tree root. Navigating into that
directory or any child loads those secrets (for example JIRA_API_TOKEN)
without a per-project config.

Example:
  ./fnox/worktree-init.sh ~/Projects
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -eq 0 ]]; then
  usage
  [[ $# -eq 0 ]] && exit 2
  exit 0
fi

require_fnox
ensure_global_keychain_provider

for dir in "$@"; do
  [[ -n "$dir" ]] || die "empty directory argument"
  ensure_worktree_config "$dir"
done

info ""
info "Next:"
info "  printf '%s' \"\$value\" | fnox -c <dir>/fnox.toml set JIRA_API_TOKEN --provider keychain"
info "  or: just secrets-migrate <dir> [dir...]"
info "Open a new shell (or eval \"\$(fnox activate zsh)\") and cd into a child directory."
