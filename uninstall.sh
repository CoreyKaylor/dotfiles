#!/bin/sh

# Remove symbolic links for dotfiles
for i in _*
do
  rm -fr "${HOME}/${i/_/.}"
done

# Note: Homebrew packages are NOT uninstalled automatically
# To completely remove Homebrew and all packages on macOS, run:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
# 
# To only remove packages installed from Brewfile:
#   brew bundle cleanup --force
#
# The Brewfile remains in the repository for easy reinstallation
