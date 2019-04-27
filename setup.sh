#!/bin/bash
mkdir -p ~/.config
rm -rf ~/.vimrc ~/.vim ~/.antigen ~/.emacs.d ~/.oh-my-zsh ~/.zshrc ~/.config/nvim
curr_dir=$(cd `dirname $0` && pwd)
ln -sf ${curr_dir}/vimreboot ~/.vim
ln -sf ${curr_dir}/vimreboot/init.vim ~/.vimrc
ln -sf ${curr_dir}/ctags ~/.ctags
ln -sf ${curr_dir}/zshrc ~/.zshrc
ln -sf ${curr_dir}/.tmux.conf ~/.tmux.conf
ln -sf ${curr_dir}/gitconfig ~/.gitconfig
ln -sf ${curr_dir}/nvim ~/.config/nvim

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
    sudo apt-get install -y curl pv httpie vim-nox zsh cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term nodejs npm direnv ruby jq git-hub iputils-ping gawk
    sudo ln -sf /usr/bin/nodejs /usr/bin/node
    if [ -z `which go` ]; then
      curl -sL https://dl.google.com/go/$(curl --silent https://golang.org/doc/devel/release.html | grep -Eo 'go[0-9]+(\.[0-9]+)+' | sort -V | uniq | tail -1).linux-amd64.tar.gz | sudo tar -C /usr/local -xz
      echo 'export PATH="/usr/local/go/bin:$PATH"' | sudo tee /etc/profile.d/golang.sh
      source /etc/profile.d/golang.sh
    fi
    sudo curl -o /usr/bin/prettyping -L --progress https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
    sudo chmod +x /usr/bin/prettyping
    curl -o /tmp/bat.deb -L --progress $(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | contains("amd64.deb") and contains("bat_")) | .browser_download_url')
    sudo dpkg -i /tmp/bat.deb
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-cosmic main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo npm install -g diff-so-fancy
    sudo apt-get update 
    sudo apt-get install -y build-essential yarn kubectl neovim python-dev ruby-dev python3-dev python3-pip cmake python-dev python-pip clang libclang-dev google-cloud-sdk
    sudo gem install neovim
    sudo pip install pynvim
    sudo pip3 install pynvim
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
      echo "==> installing go"
      curl -sL https://dl.google.com/go/$(curl --silent https://golang.org/doc/devel/release.html | grep -Eo 'go[0-9]+(\.[0-9]+)+' | sort -V | uniq | tail -1).linux-amd64.tar.gz | sudo tar -C /usr/local -xz
      echo 'export PATH="/usr/local/go/bin:$PATH"' | sudo tee /etc/profile.d/golang.sh
    fi
  fi
fi

if [ "${ID}" != "fedora" ]; then
  GH_HUB_VERSION=2.10.0
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
nvim +'PlugInstall --sync' +qall >/dev/null

echo "Installing jshint jshint jslint jsonlint tidy-markdown"
$NPM -g install jshint jslint jsonlint tidy-markdown

echo "installing markdown lint"
$GEM install mdl

echo "installing jsyaml"
$NPM -g install js-yaml

# echo "Installing jsbeautify"
# cd ~/.vim/bundle/js-beautify
# git submodule update --init --recursive

# echo "Installing YouCompleteMe"
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer --gocode-completer

go get -u -v golang.org/x/tools/cmd/...

cd ${curr_dir}
echo "Environment has been configured."
