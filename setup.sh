#!/usr/bin/env bash
rm -rf ~/.vimrc ~/.vim ~/.antigen ~/.emacs.d ~/.oh-my-zsh ~/.zshrc
curr_dir=$(cd `dirname $0` && pwd)
ln -sf ${curr_dir}/vimreboot ~/.vim
ln -sf ${curr_dir}/vimreboot/vimrc ~/.vimrc
ln -sf ${curr_dir}/ctags ~/.ctags
ln -sf ${curr_dir}/antigen ~/.antigen
ln -sf ${curr_dir}/zshrc ~/.zshrc
ln -sf ${curr_dir}/.tmux.conf ~/.tmux.conf
ln -sf ${curr_dir}/gitconfig ~/.gitconfig

echo "Installing vim plugins"
vim -e -c 'BundleInstall' -c 'qall' > /dev/null

echo "Installing YouCompleteMe dependencies"
if [ `uname` = 'Darwin' ]; then
  brew install cmake nodejs
  echo "Installing jshint"
  npm -g install jshint jslint

  echo "installing jsonlint"
  npm -g install jsonlint

  echo "installing markdown lint"
  gem install mdl

  echo "installing jsyaml"
  npm -g install js-yaml

  echo "Installing jsbeautify"
  cd ~/.vim/bundle/js-beautify
  git submodule update --init --recursive
fi
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "${ID_LIKE}" = "debian" ]; then
    sudo apt-get install -y cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term nodejs npm
    sudo ln -sf /usr/bin/nodejs /usr/bin/node
  fi
fi
if [ -f /etc/redhat-release ]; then
  sudo yum install -y cmake28 python-devel clang clang-devel ctags ncurses-term ncurses-devel nodejs npm

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
