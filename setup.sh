#!/usr/bin/env bash
rm -rf ~/.vimrc ~/.vim ~/.emacs.d ~/.oh-my-zsh ~/.zshrc
curr_dir=$(cd `dirname $0` && pwd)
ln -sf ${curr_dir}/vimreboot ~/.vim
ln -sf ${curr_dir}/vimreboot/vimrc ~/.vimrc
ln -sf ${curr_dir}/ctags ~/.ctags
# ln -sf ${curr_dir}/vim-addons ~/.vim-addons
# ln -sf ${curr_dir}/emacs.d ~/.emacs.d
ln -sf ${curr_dir}/oh-my-zsh ~/.oh-my-zsh
cp ${curr_dir}/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
ln -sf ${curr_dir}/.tmux.conf ~/.tmux.conf
ln -sf ${curr_dir}/gitconfig ~/.gitconfig

echo "Installing vim plugins"

if [ `uname` = 'Darwin' ]; then 
  $(mvim -ve -c 'BundleInstall' -c 'qall')
else
  $(vim -e -c 'BundleInstall' -c 'qall')
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "${ID_LIKE}" = debian ]; then
    sudo aptitude install cmake python-dev clang libclang-dev
  fi
fi
if [ -f /etc/redhat-release ]; then
  sudo yum install cmake28 python-devel clang clang-devel
fi


cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
cd ${curr_dir}

echo "Environment has been configured."
