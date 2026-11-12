set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

install:
  ./install.sh

uninstall:
  ./uninstall.sh

check:
  mkdir -p /tmp/dotfiles-stow-check
  stow --dir=. --target=/tmp/dotfiles-stow-check --simulate --restow zsh tmux nvim mise git lazygit herdr ghostty ssh omarchy
  bash -n omarchy/.config/omarchy/hooks/theme-set.d/10-owe-sync
  jq empty omarchy/.config/omarchy/shell.json omarchy/.config/omarchy/plugins/workspace-background/manifest.json
  zsh -n zsh/.zshrc
  zsh -n zsh/.zprofile
  zsh -n zsh/.zshenv
  zsh -n zsh/.zsh/fnox.zsh
  bash -n fnox/lib.sh
  bash -n fnox/worktree-init.sh
  bash -n fnox/check-hierarchy.sh
  bash -n fnox/config-docs.sh
  ./fnox/check-hierarchy.sh
  XDG_STATE_HOME=/tmp/nvim-state nvim --clean --headless '+set runtimepath+={{justfile_directory()}}/nvim/.config/nvim' '+luafile {{justfile_directory()}}/nvim/.config/nvim/lua/user/lsp.lua' +qa
  nvim --clean --headless '+luafile {{justfile_directory()}}/nvim/.config/nvim/lua/user/html.lua' +qa

secrets-worktree *dirs:
  ./fnox/worktree-init.sh {{dirs}}

secrets-docs *args:
  ./fnox/config-docs.sh {{args}}

brew-check:
  brew bundle check --file=./Brewfile

shell-time:
  time zsh -i -c 'exit 0'

nvim-startup:
  nvim --startuptime /tmp/nvim-startuptime.log +qa
  tail -20 /tmp/nvim-startuptime.log

nvim-profile:
  nvim --headless "+Lazy! profile" +qa

# Report omarchy package files that drifted from the repo: a link an Omarchy
# migration or `omarchy refresh` replaced with a real file, or a shell.json
# (copied, not linked) changed by bar edits. Rerun ./install.sh to relink.
omarchy-drift:
  #!/usr/bin/env bash
  set -eu
  status=0
  while IFS= read -r file; do
    rel="${file#omarchy/}"
    target="$HOME/$rel"
    if [[ "$rel" == .config/omarchy/shell.json ]]; then
      cmp -s "$file" "$target" && continue
      echo "differs: ~/$rel (just omarchy-save keeps the live one)"
    elif [[ "$(readlink -f "$target" 2>/dev/null)" != "$PWD/$file" ]]; then
      echo "not linked: ~/$rel"
    else
      continue
    fi
    [[ -f "$target" ]] && diff -u "$file" "$target" || true
    status=1
  done < <(find omarchy -type f ! -name .stow-local-ignore | sort)
  if ! grep -qxF 'require("hypr.dotfiles")' ~/.config/hypr/hyprland.lua; then
    echo 'missing: require("hypr.dotfiles") in ~/.config/hypr/hyprland.lua'
    status=1
  fi
  [[ $status -eq 0 ]] && echo "All omarchy files match the repo."
  exit $status

# Copy the live Omarchy shell.json (bar, dock, idle settings) into the repo.
omarchy-save:
  cp ~/.config/omarchy/shell.json omarchy/.config/omarchy/shell.json
  git diff --stat -- omarchy/.config/omarchy/shell.json
