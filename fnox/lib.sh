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

ensure_global_op_provider() {
  local config vault
  config="$(global_config_path)"
  vault="${FNOX_OP_VAULT:-Dev}"

  if [[ ! -f "$config" ]]; then
    fnox init --global --skip-wizard --non-interactive
  fi

  if grep -Eq '^\[providers\.op\]' "$config" 2>/dev/null; then
    return
  fi

  printf '\n[providers.op]\ntype = "1password"\nvault = "%s"\n' "$vault" >>"$config"
  info "Added 1Password provider \"op\" (vault $vault) to $config"
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
