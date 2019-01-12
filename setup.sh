#!/bin/bash
rm -rf ~/.vimrc ~/.vim ~/.antigen ~/.emacs.d ~/.oh-my-zsh ~/.zshrc
curr_dir=$(cd `dirname $0` && pwd)
ln -sf ${curr_dir}/vimreboot ~/.vim
ln -sf ${curr_dir}/vimreboot/init.vim ~/.vimrc
ln -sf ${curr_dir}/ctags ~/.ctags
ln -sf ${curr_dir}/zshrc ~/.zshrc
ln -sf ${curr_dir}/.tmux.conf ~/.tmux.conf
ln -sf ${curr_dir}/gitconfig ~/.gitconfig

NPM="npm"
GEM="gem"
GO=""
echo "Installing YouCompleteMe dependencies"
if [ `uname` = 'Darwin' ]; then
  brew install cmake nodejs hub diff-so-fancy httpie tmux
fi
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "${ID_LIKE-$ID}" = "debian" ]; then
    echo "Installing for debian"
    sudo apt-get install -y curl pv httpie vim-nox zsh cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term nodejs npm direnv ruby jq
    sudo ln -sf /usr/bin/nodejs /usr/bin/node
    if [ -z `which go` ]; then
      curl -L'#' https://godeb.s3.amazonaws.com/godeb-amd64.tar.gz | pv | sudo tar -C /usr/local/bin -zx
      sudo godeb install
    fi
    sudo npm install -g diff-so-fancy
    NPM="sudo npm"
    GEM="sudo gem"
  fi
  if [ "${ID}" = "arch" ]; then
    echo "Installing for arch"
    sudo pacman -S cmake python clang go tmux ctags ncurses nodejs diff-so-fancy
  fi
  if [ "${ID}" = "fedora" ]; then
    NPM="sudo npm"
    GEM="sudo gem"
    echo "Installing for fedora"
    sudo dnf install -y kernel-headers httpie cmake clang tmux ctags-etags ncurses nodejs npm vim python-devel ruby-devel
    if [ -z `which go` ]; then
      GO_VERSION=1.6
      echo "==> installing go ${GO_VERSION}"
      curl -L https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz | sudo tar -C /usr/local -zx
      echo 'export PATH="/usr/local/go/bin:$PATH"' | sudo tee /etc/profile.d/golang.sh
      echo 'export GOPATH="/usr/local/go"' | sudo tee -a /etc/profile.d/golang.sh
    fi
  fi
fi

if [ "${ID}" != "fedora" ]; then
  GH_HUB_VERSION=2.2.2
  curl -L'#' "https://github.com/github/hub/releases/download/v$GH_HUB_VERSION/hub-linux-amd64-$GH_HUB_VERSION.tar.gz" | tar -C /tmp
  cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/hub" /usr/bin
  chmod +x "/usr/bin/hub"
  cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/man/hub.1" /usr/share/man/man1
  mandb
  mkdir -p /usr/share/bash-completion /usr/share/zsh/vendor-completions
  cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/etc/hub/hub.bash_completion.sh" /usr/share/bash-completion/completions/hub
  cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/etc/hub.zsh_completion" /usr/share/zsh/vendor-completions/_hub
fi

echo "Installing vim plugins"
script -qfc "vim -e +qall" /dev/null > /dev/null

echo "Installing jshint jshint jslint jsonlint tidy-markdown"
$NPM -g install jshint jslint jsonlint tidy-markdown

echo "installing markdown lint"
$GEM install mdl

echo "installing jsyaml"
$NPM -g install js-yaml

# echo "Installing jsbeautify"
# cd ~/.vim/bundle/js-beautify
# git submodule update --init --recursive

echo "Installing YouCompleteMe"
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer --gocode-completer

go get -u -v golang.org/x/tools/cmd/...

cd ${curr_dir}
echo "Environment has been configured."
