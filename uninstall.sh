#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(git lazygit mise nvim tmux zsh)

if ! command -v stow >/dev/null 2>&1; then
  printf '%s\n' "GNU Stow is required to uninstall these dotfiles safely."
  exit 1
fi

for package in "${PACKAGES[@]}"; do
  printf 'Unstowing %s\n' "$package"
  stow --dir="$ROOT" --target="$HOME" --delete "$package"
done

printf '%s\n' "Dotfiles uninstalled."
