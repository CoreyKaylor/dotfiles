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

if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]
then
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# git update-index --assume-unchanged modules/zsh-completions
