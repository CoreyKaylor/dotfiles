#!/usr/bin/env bash
# Move KEY=value pairs from ~/.env into the OS keychain and a work-tree fnox.toml.
set -euo pipefail
set +x

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: fnox/migrate-from-env.sh <dir> [dir...]

Read ~/.env (must be owned by you and mode <= 0600) and store each key in
the OS keychain. Names are written to each work-tree fnox.toml so cd into
those trees injects the variables.

Values are never printed. ~/.env is left in place; rename it after you
confirm fnox get KEY works.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -eq 0 ]]; then
  usage
  [[ $# -eq 0 ]] && exit 2
  exit 0
fi

require_fnox
ensure_global_keychain_provider

ENV_FILE="${FNOX_ENV_FILE:-$HOME/.env}"
[[ -r "$ENV_FILE" ]] || die "$ENV_FILE is not readable"

owner="$(stat -f %Su "$ENV_FILE" 2>/dev/null || stat -c %U "$ENV_FILE" 2>/dev/null)"
mode="$(stat -f %Lp "$ENV_FILE" 2>/dev/null || stat -c %a "$ENV_FILE" 2>/dev/null)"
[[ "$owner" == "$USER" ]] || die "$ENV_FILE is owned by $owner, not $USER"
[[ "$mode" -le 600 ]] || die "$ENV_FILE has mode $mode (need <= 0600)"

worktrees=()
for dir in "$@"; do
  [[ -n "$dir" ]] || die "empty directory argument"
  ensure_worktree_config "$dir"
  worktrees+=("$dir/fnox.toml")
done

imported=0
skipped=0

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%$'\r'}"
  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  if [[ "$line" =~ ^[[:space:]]*export[[:space:]]+ ]]; then
    line="${line#*export}"
    line="${line#"${line%%[![:space:]]*}"}"
  fi

  if [[ ! "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
    info "Skipping unparsable line"
    skipped=$((skipped + 1))
    continue
  fi

  key="${BASH_REMATCH[1]}"
  value="${BASH_REMATCH[2]}"

  if [[ "$value" =~ ^\"(.*)\"[[:space:]]*$ ]]; then
    value="${BASH_REMATCH[1]}"
    value="${value//\\\\/\\}"
    value="${value//\\\"/\"}"
    value="${value//\\n/$'\n'}"
    value="${value//\\t/$'\t'}"
  elif [[ "$value" =~ ^\'(.*)\'[[:space:]]*$ ]]; then
    value="${BASH_REMATCH[1]}"
  else
    value="${value%%[[:space:]]#*}"
    value="${value%"${value##*[![:space:]]}"}"
  fi

  for dest in "${worktrees[@]}"; do
    printf '%s' "$value" | fnox --config "$dest" set "$key" --provider keychain --non-interactive
  done

  info "Imported $key"
  imported=$((imported + 1))
done <"$ENV_FILE"

info ""
info "Imported $imported secret(s), skipped $skipped line(s)."
info "Check with: (cd $1 && fnox list && fnox get <KEY>)"
info "When that looks right: mv $ENV_FILE $ENV_FILE.bak"
