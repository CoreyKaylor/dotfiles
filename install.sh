#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux nvim mise git lazygit)

info() {
  printf '%s\n' "$*"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

ensure_homebrew() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return
  fi

  if ! has brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  eval "$(brew shellenv)"
}

ensure_packages() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ensure_homebrew
    brew bundle install --file="$ROOT/Brewfile"
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

stow_packages() {
  for package in "${PACKAGES[@]}"; do
    info "Stowing $package"
    stow --dir="$ROOT" --target="$HOME" --restow "$package"
  done
}

ensure_packages
remove_stale_underscore_links
stow_packages

info "Dotfiles installed."
