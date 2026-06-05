set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

install:
  ./install.sh

uninstall:
  ./uninstall.sh

check:
  mkdir -p /tmp/dotfiles-stow-check
  stow --dir=. --target=/tmp/dotfiles-stow-check --simulate --restow zsh tmux nvim mise git lazygit
  zsh -n zsh/.zshrc
  zsh -n zsh/.zprofile
  zsh -n zsh/.zshenv
  XDG_STATE_HOME=/tmp/nvim-state nvim --clean --headless '+set runtimepath+={{justfile_directory()}}/nvim/.config/nvim' '+luafile {{justfile_directory()}}/nvim/.config/nvim/lua/user/lsp.lua' +qa
  nvim --clean --headless '+luafile {{justfile_directory()}}/nvim/.config/nvim/lua/user/html.lua' +qa

brew-check:
  brew bundle check --file=./Brewfile

shell-time:
  time zsh -i -c 'exit 0'

nvim-startup:
  nvim --startuptime /tmp/nvim-startuptime.log +qa
  tail -20 /tmp/nvim-startuptime.log

nvim-profile:
  nvim --headless "+Lazy! profile" +qa
