#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(git jj lazygit mise nvim tmux zsh herdr ghostty ssh)

if ! command -v stow >/dev/null 2>&1; then
  printf '%s\n' "GNU Stow is required to uninstall these dotfiles safely."
  exit 1
fi

for package in "${PACKAGES[@]}"; do
  printf 'Unstowing %s\n' "$package"
  stow --dir="$ROOT" --target="$HOME" --delete "$package"
done

# hyprland.lua require()s hypr/dotfiles.lua (install.sh adds the line), so
# removing the link would break the session. Leave real copies of the omarchy
# package in place instead; they stop tracking the repo.
if [[ -d /usr/share/omarchy ]]; then
  printf '%s\n' "Unstowing omarchy (keeping copies)"
  stow --dir="$ROOT" --target="$HOME" --delete omarchy
  while IFS= read -r -d '' file; do
    rel="${file#"$ROOT/omarchy/"}"
    [[ -e "$HOME/$rel" ]] && continue
    mkdir -p "$(dirname "$HOME/$rel")"
    cp -p "$file" "$HOME/$rel"
  done < <(find "$ROOT/omarchy" -type f ! -name .stow-local-ignore -print0)
fi

printf '%s\n' "Dotfiles uninstalled."
