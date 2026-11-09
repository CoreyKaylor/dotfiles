#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux nvim mise git lazygit herdr ghostty ssh)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() {
  printf '%s\n' "$*"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_arch() {
  [[ -f /etc/arch-release ]]
}

ai_cli_path() {
  printf '%s\n' "$HOME/.local/bin:$HOME/.grok/bin:$PATH"
}

has_ai_cli() {
  PATH="$(ai_cli_path)" command -v "$1" >/dev/null 2>&1
}

fetch_url() {
  local url="$1"

  if has curl; then
    curl -fsSL "$url"
    return
  fi

  if has wget; then
    wget -q -O - "$url"
    return
  fi

  info "curl or wget is required to install AI CLIs."
  exit 1
}

profileless_shell() {
  if [[ -x /usr/bin/false ]]; then
    printf '%s\n' /usr/bin/false
  elif [[ -x /bin/false ]]; then
    printf '%s\n' /bin/false
  else
    printf '%s\n' false
  fi
}

brew_path() {
  local candidate

  if candidate="$(command -v brew 2>/dev/null)"; then
    printf '%s\n' "$candidate"
    return
  fi

  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
}

ensure_homebrew() {
  if ! is_macos; then
    return
  fi

  local brew_bin

  if ! has brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew_bin="$(brew_path || true)"
  if [[ -z "$brew_bin" ]]; then
    info "Homebrew installed, but brew was not found in the expected locations."
    exit 1
  fi

  eval "$("$brew_bin" shellenv)"
}

aur_helper() {
  local helper
  for helper in yay paru; do
    if has "$helper"; then
      printf '%s\n' "$helper"
      return
    fi
  done
}

ensure_arch_packages() {
  local helper
  local -a packages

  helper="$(aur_helper || true)"
  if [[ -z "$helper" ]]; then
    info "An AUR helper (yay or paru) is required to install the Archfile. Install one, then rerun ./install.sh."
    exit 1
  fi

  mapfile -t packages < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$ROOT/Archfile")
  info "Installing Archfile packages with $helper..."
  "$helper" -S --needed --noconfirm "${packages[@]}"
}

ensure_packages() {
  if is_macos; then
    ensure_homebrew
    brew bundle install --file="$ROOT/Brewfile"
    return
  fi

  if is_arch; then
    ensure_arch_packages
    return
  fi

  if ! has stow; then
    info "GNU Stow is required. Install it with your system package manager, then rerun ./install.sh."
    exit 1
  fi
}

remove_stale_underscore_links() {
  local targets=(
    "$HOME/.config"
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.zshenv"
    "$HOME/.zsh_plugins.txt"
    "$HOME/.tmux.conf"
    "$HOME/.gitconfig"
  )

  local target link
  for target in "${targets[@]}"; do
    [[ -L "$target" ]] || continue
    link="$(readlink "$target")"
    case "$link" in
      "$ROOT"/_*|"$ROOT"/_config|"$ROOT"/_config/*)
        info "Removing stale link $target -> $link"
        unlink "$target"
        ;;
    esac
  done
}

# True when the path is, or resolves through, a link into this repo.
owned_by_repo() {
  local resolved
  resolved="$(readlink -f "$1" 2>/dev/null)" || return 1
  [[ "$resolved" == "$ROOT"/* ]]
}

# Move ~/REL into the backup dir unless it is missing or already ours.
backup_if_foreign() {
  local rel="$1"
  local target="$HOME/$rel"

  [[ -e "$target" || -L "$target" ]] || return 1
  owned_by_repo "$target" && return 1

  mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
  mv "$target" "$BACKUP_DIR/$rel"
  info "Backed up ~/$rel -> $BACKUP_DIR/$rel"
}

# Stow refuses to replace real files, so distro defaults (Omarchy ships
# nvim, lazygit, herdr and git configs) are moved aside first.
backup_conflicts() {
  local package file rel

  # Configs the repo owns outright. Merging a stowed tree into an existing
  # one (LazyVim's plugin/ dir, for example) would leave both half-active.
  if backup_if_foreign .config/nvim; then
    # LazyVim's plugins, mason tools and parsers do not belong to this config.
    backup_if_foreign .local/share/nvim || true
    backup_if_foreign .local/state/nvim || true
  fi

  # Git reads ~/.config/git/config before ~/.gitconfig, so a distro copy
  # (Omarchy ships one) would quietly layer settings (pull.rebase, aliases)
  # under the repo's. On macOS that file would be your own, so leave it.
  if ! is_macos; then
    backup_if_foreign .config/git/config || true
  fi

  for package in "${PACKAGES[@]}"; do
    while IFS= read -r -d '' file; do
      rel="${file#"$ROOT/$package/"}"
      backup_if_foreign "$rel" || true
    done < <(find "$ROOT/$package" \( -type f -o -type l \) -print0)
  done
}

stow_packages() {
  # Real dir so stow only links config.toml and herdr runtime (plugins/) stays out of the package.
  mkdir -p "$HOME/.config/herdr"
  # Real dirs so runtime state (lazygit state.yml, mise conf.d/) stays out of the repo.
  mkdir -p "$HOME/.config/lazygit" "$HOME/.config/mise"
  # Real dirs so machine-local files (ghostty/config, git/local) stay out of the repo.
  mkdir -p "$HOME/.config/ghostty" "$HOME/.config/git"
  # Real, private dir so stow links individual files and keys never land in the repo.
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  for package in "${PACKAGES[@]}"; do
    info "Stowing $package"
    stow --dir="$ROOT" --target="$HOME" --restow "$package"
  done
}

# ~/.config/ghostty/config is machine-local (Omarchy rewrites font settings in
# it), so the shared settings come in through an include instead of a link.
ensure_ghostty_include() {
  local config="$HOME/.config/ghostty/config"
  local line='config-file = ?dotfiles.conf'

  if [[ -f "$config" ]] && grep -qxF "$line" "$config"; then
    return
  fi

  info "Adding the dotfiles include to $config"
  {
    [[ -s "$config" ]] && printf '\n'
    printf '%s\n' "# Shared settings from the dotfiles repo; loaded after this file, so they win."
    printf '%s\n' "$line"
  } >>"$config"
}

# ssh/.ssh/config points IdentityAgent at ~/.1password/agent.sock, where the
# Linux app puts it. On macOS, link that path to the real socket (1Password's
# documented setup) so one ssh config works on both.
ensure_1password_agent_socket() {
  is_macos || return 0
  local sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  mkdir -p "$HOME/.1password"
  chmod 700 "$HOME/.1password"
  ln -sfn "$sock" "$HOME/.1password/agent.sock"
}

ensure_git_signing() {
  local candidate op_ssh_sign=""
  for candidate in \
    /Applications/1Password.app/Contents/MacOS/op-ssh-sign \
    /opt/1Password/op-ssh-sign
  do
    if [[ -x "$candidate" ]]; then
      op_ssh_sign="$candidate"
      break
    fi
  done

  if [[ -z "$op_ssh_sign" ]]; then
    info "1Password op-ssh-sign not found; commit signing falls back to ssh-keygen via SSH_AUTH_SOCK."
    return
  fi

  # Machine-local: the path differs per OS and only exists with 1Password installed.
  mkdir -p "$HOME/.config/git"
  git config --file "$HOME/.config/git/local" gpg.ssh.program "$op_ssh_sign"
}

ensure_ai_cli() {
  local command_name="$1"
  local install_url="$2"
  local runner="$3"
  local shell_path

  if has_ai_cli "$command_name"; then
    # Omarchy declares AI CLIs as lazy mise tools: the command is a wrapper
    # that downloads on first run. Install it now so it works offline.
    if [[ "$(PATH="$(ai_cli_path)" command -v "$command_name")" == */mise/command-wrappers/* ]]; then
      info "Installing $command_name via mise..."
      mise install "$command_name"
      return
    fi
    info "$command_name already installed."
    return
  fi

  info "Installing $command_name..."
  shell_path="$(profileless_shell)"

  case "$command_name" in
    codex)
      fetch_url "$install_url" | PATH="$(ai_cli_path)" SHELL="$shell_path" CODEX_NON_INTERACTIVE=1 "$runner"
      ;;
    *)
      fetch_url "$install_url" | PATH="$(ai_cli_path)" SHELL="$shell_path" "$runner"
      ;;
  esac
}

ensure_ai_clis() {
  ensure_ai_cli claude "https://claude.ai/install.sh" bash
  ensure_ai_cli grok "https://x.ai/cli/install.sh" bash
  ensure_ai_cli codex "https://chatgpt.com/codex/install.sh" sh
}

ensure_herdr_plugin() {
  if ! has herdr; then
    info "herdr not installed; skip herdr-splits plugin."
    return
  fi

  if herdr plugin list 2>/dev/null | grep -q 'herdr-splits'; then
    info "herdr-splits plugin already installed."
    return
  fi

  info "Installing herdr-splits plugin for seamless nvim navigation..."
  herdr plugin install lmilojevicc/herdr-splits.nvim --yes || {
    info "herdr plugin install failed (server may need to run once). Install later with:"
    info "  herdr plugin install lmilojevicc/herdr-splits.nvim"
  }
}

ensure_fnox() {
  if has fnox; then
    info "fnox already installed."
    return
  fi

  if has mise; then
    # The AUR package is x86_64 only, so Linux uses mise. Write to conf.d so
    # the stowed ~/.config/mise/config.toml (tracked in this repo) stays clean.
    info "Installing fnox via mise..."
    mise use --path "$HOME/.config/mise/conf.d/fnox.toml" fnox@latest
    return
  fi

  info "fnox is not installed. On macOS it comes from the Brewfile. On Linux: install mise, then rerun."
}

# Grok Bot (Cursor/xAI's desktop agent). The AUR packages are x86_64 only, so
# arm64 uses the official AppImage, unpacked because Omarchy has no fuse2.
# Rerunning install.sh picks up new releases.
GROK_BOT_DIR="$HOME/.local/share/grok-bot"

ensure_grok_bot() {
  is_arch || return 0

  case "$(uname -m)" in
    x86_64)
      "$(aur_helper)" -S --needed --noconfirm grok-bot-bin
      ;;
    aarch64)
      ensure_grok_bot_appimage linux-arm64
      ;;
    *)
      info "No Grok Bot build for $(uname -m); skipping."
      ;;
  esac
}

ensure_grok_bot_appimage() {
  local platform="$1"
  local api="https://api2.cursor.sh/updates/api/update/$platform/sand/0.0.0/00000000-0000-0000-0000-000000000000/stable"
  local meta version url sha tmp desktop icon

  meta="$(fetch_url "$api")"
  version="$(jq -r .version <<<"$meta")"
  url="$(jq -r .url <<<"$meta")"
  sha="$(jq -r .sha256hash <<<"$meta")"

  if [[ "$(cat "$GROK_BOT_DIR/.version" 2>/dev/null)" == "$version" ]]; then
    info "Grok Bot $version already installed."
    return
  fi

  info "Installing Grok Bot $version..."
  tmp="$(mktemp -d)"
  fetch_url "$url" >"$tmp/grok-bot.AppImage"
  if ! printf '%s  %s\n' "$sha" "$tmp/grok-bot.AppImage" | sha256sum --check --status; then
    info "Grok Bot download failed its checksum; skipping."
    rm -rf "$tmp"
    return
  fi
  chmod +x "$tmp/grok-bot.AppImage"
  (cd "$tmp" && ./grok-bot.AppImage --appimage-extract >/dev/null)

  rm -rf "$GROK_BOT_DIR"
  mkdir -p "$(dirname "$GROK_BOT_DIR")" "$HOME/.local/bin" "$HOME/.local/share/applications"
  mv "$tmp/squashfs-root" "$GROK_BOT_DIR"
  printf '%s\n' "$version" >"$GROK_BOT_DIR/.version"
  rm -rf "$tmp"

  printf '#!/bin/sh\nexec "%s/AppRun" "$@"\n' "$GROK_BOT_DIR" >"$HOME/.local/bin/grok-bot"
  chmod +x "$HOME/.local/bin/grok-bot"

  # Point the bundled launcher entry at the unpacked app so it shows in the app launcher.
  desktop="$(find "$GROK_BOT_DIR" -maxdepth 1 -name '*.desktop' | head -n1)"
  if [[ -n "$desktop" ]]; then
    icon="$(sed -n 's/^Icon=//p' "$desktop" | head -n1)"
    sed -e "s|^Exec=[^ ]*|Exec=$HOME/.local/bin/grok-bot|" \
      -e "s|^Icon=.*|Icon=$GROK_BOT_DIR/$icon.png|" \
      "$desktop" >"$HOME/.local/share/applications/grok-bot.desktop"
  fi
}

# Tailscale comes from the Archfile; the daemon has to be enabled before
# `tailscale up` can log the machine in.
ensure_tailscale() {
  is_arch || return 0
  has tailscale || return 0

  if ! systemctl is-enabled --quiet tailscaled; then
    info "Enabling tailscaled..."
    sudo systemctl enable --now tailscaled
  fi

  if ! tailscale status >/dev/null 2>&1; then
    info "Tailscale is not logged in. Run: sudo tailscale up"
  fi
}

ensure_tpm() {
  local tpm="$HOME/.tmux/plugins/tpm"
  [[ -d "$tpm" ]] && return
  info "Installing tmux plugin manager..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
}

ensure_login_shell() {
  is_macos && return
  has zsh || return 0

  local zsh_path current
  zsh_path="$(command -v zsh)"
  current="$(getent passwd "$USER" | cut -d: -f7)"
  [[ "$(basename "$current")" == zsh ]] && return

  if [[ -t 0 ]]; then
    info "Changing login shell to $zsh_path (chsh asks for your password)..."
    chsh -s "$zsh_path" && return
  fi
  info "Login shell is still $current. Change it with: chsh -s $zsh_path"
}

print_next_steps() {
  is_macos && return
  info ""
  info "Next, in the 1Password app (sign in first):"
  info "  Settings > Developer > Use the SSH agent            (creates ~/.1password/agent.sock)"
  info "  Settings > Developer > Integrate with 1Password CLI (op and fnox unlock through the app)"
  info "Then check:"
  info "  ssh -T git@github.com"
  info "  git -C \"$ROOT\" remote set-url origin git@github.com:CoreyKaylor/dotfiles.git"
  info "Log out and back in (or open a new terminal) to start zsh."
}

ensure_packages
remove_stale_underscore_links
backup_conflicts
stow_packages
ensure_ghostty_include
ensure_1password_agent_socket
ensure_git_signing
ensure_fnox
ensure_tpm
ensure_ai_clis
ensure_grok_bot
ensure_tailscale
ensure_herdr_plugin
ensure_login_shell

info "Dotfiles installed."
print_next_steps
