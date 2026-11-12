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

is_omarchy() {
  [[ -d /usr/share/omarchy ]]
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
      # Not stowed (see omarchy/.stow-local-ignore); ensure_omarchy_shell_config copies it.
      [[ "$rel" == .stow-local-ignore || "$package/$rel" == omarchy/.config/omarchy/shell.json ]] && continue
      backup_if_foreign "$rel" || true
    done < <(find "$ROOT/$package" \( -type f -o -type l \) -print0)
  done
}

stow_packages() {
  # Real dir so stow only links config.toml and herdr runtime (plugins/) stays out of the package.
  mkdir -p "$HOME/.config/herdr"
  # Real dirs so runtime state (lazygit state.yml, other mise conf.d/ files) stays
  # out of the repo; stow links only conf.d/fnox.toml.
  mkdir -p "$HOME/.config/lazygit" "$HOME/.config/mise/conf.d"
  # Real dirs so machine-local files (ghostty/config, git/local) stay out of the repo.
  mkdir -p "$HOME/.config/ghostty" "$HOME/.config/git"
  # Real, private dir so stow links individual files and keys never land in the repo.
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  # Real dirs so stow links individual files: Omarchy keeps its own files in
  # hypr/, and packages drop plugins and hooks (superwhisper-panel, the
  # .sample hooks) beside ours that must not land in the repo.
  if is_omarchy; then
    mkdir -p "$HOME/.config/hypr" "$HOME/.config/omarchy/plugins" "$HOME/.config/omarchy/hooks/theme-set.d"
  fi

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

# Omarchy saves shell.json by renaming a new file over it, which would replace
# a symlink, so it is copied rather than stowed. Only Omarchy's stock copy (or
# no file) is replaced; a customized one is left alone so bar changes made on
# this machine are not lost. `just omarchy-save` copies it back into the repo.
ensure_omarchy_shell_config() {
  is_omarchy || return 0
  local repo="$ROOT/omarchy/.config/omarchy/shell.json"
  local live="$HOME/.config/omarchy/shell.json"
  local stock=/usr/share/omarchy/config/omarchy/shell.json

  cmp -s "$repo" "$live" && return
  if [[ ! -e "$live" ]] || cmp -s "$stock" "$live"; then
    info "Copying the dotfiles shell.json to $live"
    mkdir -p "$(dirname "$live")"
    [[ -e "$live" ]] && backup_if_foreign .config/omarchy/shell.json
    cp "$repo" "$live"
    return
  fi
  info "$live differs from the repo copy; left as is."
  info "  Keep the repo's: cp $repo $live"
  info "  Keep this one:   just omarchy-save"
}

# Omarchy defaults to foot; ghostty/ carries the terminal config, so make it
# the terminal Super+Return and xdg-terminal-exec open.
ensure_omarchy_terminal() {
  is_omarchy && has ghostty || return 0
  [[ "$(omarchy-default-terminal)" == ghostty ]] && return
  info "Setting Ghostty as Omarchy's default terminal"
  omarchy-default-terminal ghostty
}

# ~/.config/hypr/hyprland.lua is Omarchy's (migrations edit it), so the repo's
# overrides come in through one require line instead of a link. It goes before
# Omarchy's runtime toggles so a toggle (touchpad off, say) still wins.
ensure_hypr_dotfiles_include() {
  is_omarchy || return 0
  local config="$HOME/.config/hypr/hyprland.lua"
  local line='require("hypr.dotfiles")'
  local anchor='require("default.hypr.toggles")'

  [[ -f "$config" ]] || return 0
  grep -qxF "$line" "$config" && return

  info "Adding the dotfiles require to $config"
  if grep -qxF "$anchor" "$config"; then
    local tmp
    tmp="$(mktemp)"
    # Insert above the anchor and the comment block directly over it.
    awk -v line="$line" -v anchor="$anchor" '
      { lines[NR] = $0 }
      $0 == anchor { at = NR; while (at > 1 && lines[at - 1] ~ /^--/) at-- }
      END {
        for (i = 1; i <= NR; i++) {
          if (i == at) { print "-- Personal overrides from the dotfiles repo."; print line; print "" }
          print lines[i]
        }
      }
    ' "$config" >"$tmp"
    cat "$tmp" >"$config"
    rm -f "$tmp"
  else
    printf '\n%s\n%s\n' "-- Personal overrides from the dotfiles repo." "$line" >>"$config"
  fi
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

# Installs the global tools in ~/.config/mise/config.toml and conf.d/fnox.toml
# (fnox's AUR package is x86_64 only, so Linux gets it from mise). Omarchy's
# own lazy tools in /etc/mise/conf.d are left to install on first use.
ensure_mise_tools() {
  if ! has mise; then
    info "mise is not installed; skipping mise tools. Install mise, then rerun."
    return
  fi

  info "Installing mise tools..."
  (cd "$HOME" && mise install)
}

# fnox reads 1Password through this per-machine config; it is not in the repo.
check_fnox_config() {
  local config="$HOME/.config/fnox/config.toml"
  [[ -f "$config" ]] && return
  info "Missing $config. Create it with:"
  info "  [providers.op]"
  info "  type = \"1password\""
  info "  vault = \"Dev\""
}

# Docker comes from the Archfile. The group change applies at next login.
ensure_docker() {
  is_arch || return 0
  has docker || return 0

  if ! systemctl is-enabled --quiet docker; then
    info "Enabling docker..."
    sudo systemctl enable --now docker
  fi

  if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    info "Adding $USER to the docker group (log out and back in for it to apply)..."
    sudo usermod -aG docker "$USER"
  fi
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

# diffbandit.nvim ships a launcher script: `diffbandit` and `git diffbandit`.
# It just starts nvim and runs :DiffBanditLaunch, so it uses whichever copy of
# the plugin the nvim config loads; link it from the vim.pack-managed copy.
ensure_diffbandit_cli() {
  has nvim || return 0

  local script="$HOME/.local/share/nvim/site/pack/core/opt/diffbandit.nvim/bin/diffbandit"
  if [[ ! -x "$script" ]]; then
    info "Installing nvim plugins..."
    nvim --headless +qa >/dev/null 2>&1 || true
  fi
  if [[ ! -x "$script" ]]; then
    info "diffbandit.nvim is not installed; skipping the diffbandit CLI."
    return
  fi

  mkdir -p "$HOME/.local/bin"
  ln -sfn "$script" "$HOME/.local/bin/diffbandit"
  ln -sfn "$script" "$HOME/.local/bin/git-diffbandit"
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

# Omarchy overrides: hypr/dotfiles.lua (monitors, input, look), shell.json,
# the workspace-background plugin and the owe hook.
is_omarchy && PACKAGES+=(omarchy)

ensure_packages
remove_stale_underscore_links
backup_conflicts
stow_packages
ensure_omarchy_shell_config
ensure_hypr_dotfiles_include
ensure_omarchy_terminal
ensure_ghostty_include
ensure_1password_agent_socket
ensure_git_signing
ensure_mise_tools
check_fnox_config
ensure_tpm
ensure_ai_clis
ensure_grok_bot
ensure_tailscale
ensure_docker
ensure_herdr_plugin
ensure_diffbandit_cli
ensure_login_shell

info "Dotfiles installed."
print_next_steps
