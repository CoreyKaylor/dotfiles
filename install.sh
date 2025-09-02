#!/bin/sh

# submodules

git submodule init
git submodule update

# make symbolic links

link_file() {
  source="${PWD}/$1"
  target="${HOME}/${1/_/.}"

  if [ -e $target ] ; then
    if [ ! -d $target ] ; then
      echo "Update\t$target"
      mv $target $target.bak
      ln -sf ${source} ${target}
    fi
  else
    echo "Install\t$target"
    ln -sf ${source} ${target}
  fi
}

for i in _*
do
  link_file $i
done
link_file bin

# package install

if [ ! -d $HOME/.vim/autoload/plug.vim ]
then
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

# Homebrew setup (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Setting up Homebrew for macOS..."
    
    # Check and install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"      # Intel Mac
        fi
    else
        echo "Homebrew already installed"
    fi
    
    # Install from Brewfile if it exists
    if [ -f "Brewfile" ]; then
        echo "Installing packages from Brewfile..."
        brew bundle install
    else
        echo "No Brewfile found, skipping package installation"
    fi
else
    echo "Not on macOS, skipping Homebrew setup"
fi
