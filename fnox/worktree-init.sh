#!/usr/bin/env bash
# Set up the 1Password provider and a parent fnox.toml that children inherit.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: fnox/worktree-init.sh <dir> [dir...]

Add the 1Password provider "op" (vault ${FNOX_OP_VAULT:-Dev}) to the global
fnox config, and write a references-only fnox.toml at each work-tree root.
Navigating into that directory or any child loads those secrets (for
example JIRA_API_TOKEN) without a per-project config.

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
ensure_global_op_provider

for dir in "$@"; do
  [[ -n "$dir" ]] || die "empty directory argument"
  ensure_worktree_config "$dir"
done

info ""
info "Next:"
info "  fnox-set -s -i shared JIRA_API_TOKEN     # stores in 1Password, references it"
info "  just secrets-docs pull                   # restore fnox files kept in 1Password"
info "Open a new shell (or eval \"\$(fnox activate zsh)\") and cd into a child directory."
