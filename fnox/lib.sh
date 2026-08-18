# Shared helpers for fnox/ scripts. Source only; do not execute.

info() {
  printf '%s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_fnox() {
  command -v fnox >/dev/null 2>&1 || die "fnox is not installed. On macOS: brew bundle install. On Linux: mise use -g fnox"
}

global_config_path() {
  printf '%s\n' "${FNOX_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/fnox}/config.toml"
}

ensure_global_keychain_provider() {
  local config
  config="$(global_config_path)"

  if [[ ! -f "$config" ]]; then
    fnox init --global --skip-wizard --non-interactive
  fi

  if grep -Eq '^\[providers(\.keychain)?\]' "$config" 2>/dev/null &&
    grep -Eq 'type[[:space:]]*=[[:space:]]*"keychain"' "$config" 2>/dev/null; then
    return
  fi

  case "$(uname -s)" in
    Darwin) fnox provider add keychain keychain --global --non-interactive ;;
    *) info "Skipping keychain provider on $(uname -s); add an age identity under $config instead." ;;
  esac
}

ensure_worktree_config() {
  local dir="$1"
  local dest="$dir/fnox.toml"

  mkdir -p "$dir"

  if [[ -e "$dest" ]]; then
    info "Keeping existing $dest"
    return
  fi

  fnox --config "$dest" init --skip-wizard --non-interactive
  info "Wrote $dest"
}
