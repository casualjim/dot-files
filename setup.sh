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
vim -e -c 'BundleInstall' -c 'qall' > /dev/null

echo "Installing YouCompleteMe dependencies"
if [ `uname` = 'Darwin' ]; then
  brew install cmake 
fi
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "${ID_LIKE}" = debian ]; then
    sudo aptitude install -y cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term
    cd /tmp
    curl -OLs https://godeb.s3.amazonaws.com/godeb-amd64.tar.gz
    sudo tar -zxf /tmp/godeb-amd64.tar.gz -C /usr/bin
    sudo /usr/bin/godeb install 1.3.1
  fi
fi
if [ -f /etc/redhat-release ]; then
  sudo yum install -y cmake28 python-devel clang clang-devel ctags ncurses-term ncurses-devel

  cd /tmp 
  wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
  tar -xvzf libevent-2.0.21-stable.tar.gz
  cd libevent-2.0.21-stable
  ./configure
  make
  sudo make install

  cd /tmp
  wget http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz
  tar -xvzf tmux-1.9a.tar.gz
  cd tmux-1.9a
  ./configure
  make
  sudo make install
fi

echo "Installing YouCompleteMe"
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
cd ${curr_dir}

echo "Environment has been configured."
