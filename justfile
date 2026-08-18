set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

install:
  ./install.sh

uninstall:
  ./uninstall.sh

check:
  mkdir -p /tmp/dotfiles-stow-check
  stow --dir=. --target=/tmp/dotfiles-stow-check --simulate --restow zsh tmux nvim mise git lazygit herdr
  zsh -n zsh/.zshrc
  zsh -n zsh/.zprofile
  zsh -n zsh/.zshenv
  zsh -n zsh/.zsh/fnox.zsh
  bash -n fnox/lib.sh
  bash -n fnox/worktree-init.sh
  bash -n fnox/migrate-from-env.sh
  bash -n fnox/check-hierarchy.sh
  ./fnox/check-hierarchy.sh
  XDG_STATE_HOME=/tmp/nvim-state nvim --clean --headless '+set runtimepath+={{justfile_directory()}}/nvim/.config/nvim' '+luafile {{justfile_directory()}}/nvim/.config/nvim/lua/user/lsp.lua' +qa
  nvim --clean --headless '+luafile {{justfile_directory()}}/nvim/.config/nvim/lua/user/html.lua' +qa

secrets-worktree *dirs:
  ./fnox/worktree-init.sh {{dirs}}

secrets-migrate *dirs:
  ./fnox/migrate-from-env.sh {{dirs}}

brew-check:
  brew bundle check --file=./Brewfile

shell-time:
  time zsh -i -c 'exit 0'

nvim-startup:
  nvim --startuptime /tmp/nvim-startuptime.log +qa
  tail -20 /tmp/nvim-startuptime.log

nvim-profile:
  nvim --headless "+Lazy! profile" +qa
