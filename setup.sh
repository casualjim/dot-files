#!/bin/bash
mkdir -p ~/.config
rm -rf ~/.vimrc ~/.vim ~/.antigen ~/.emacs.d ~/.oh-my-zsh ~/.zshrc ~/.config/nvim
curr_dir=$(cd "$(dirname "${0}")" && pwd)
ln -sf "${curr_dir}/vimreboot" ~/.vim
ln -sf "${curr_dir}/vimreboot/init.vim" ~/.vimrc
ln -sf "${curr_dir}/ctags" ~/.ctags
ln -sf "${curr_dir}/zshrc" ~/.zshrc
ln -sf "${curr_dir}/.tmux".conf ~/.tmux.conf
ln -sf "${curr_dir}/gitconfig" ~/.gitconfig
ln -sf "${curr_dir}/nvim" ~/.config/nvim
ln -sf "${curr_dir}/starship.toml" ~/.config/starship.toml

NPM="npm"
GEM="gem"
GO=""
echo "Installing YouCompleteMe dependencies"

if [ "$(uname)" = 'Darwin' ]; then
  brew install cmake nodejs hub diff-so-fancy httpie tmux ripgrep exa prettyping bat
fi

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [ "${ID_LIKE-$ID}" = "debian" ]; then
    echo "Installing for debian"
    sudo apt-get install -y curl pv httpie vim-nox zsh cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term nodejs npm direnv ruby jq git-hub iputils-ping gawk
    sudo ln -sf /usr/bin/nodejs /usr/bin/node
    if [ -z "$(which go)" ]; then
      curl -sL "https://dl.google.com/go/$(curl --silent https://golang.org/doc/devel/release.html | grep -Eo 'go[0-9]+(\.[0-9]+)+' | sort -V | uniq | tail -1).linux-amd64.tar.gz" | sudo tar -C /usr/local -xz
      # shellcheck disable=SC2016
      echo 'export PATH="/usr/local/go/bin:$PATH"' | sudo tee /etc/profile.d/golang.sh
      # shellcheck disable=SC1091
      source /etc/profile.d/golang.sh
    fi
    sudo curl -o /usr/bin/prettyping -L --progress https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
    sudo chmod +x /usr/bin/prettyping
    curl -o /tmp/bat.deb -L --progress "$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | contains("amd64.deb") and contains("bat_")) | .browser_download_url')"
    sudo dpkg -i /tmp/bat.deb
    mkdir -p /tmp/exa
    curl -o /tmp/exa/exa.zip -L --progress "$(curl -s https://api.github.com/repos/ogham/exa/releases/latest | jq -r '.assets[] | select(.name | contains("exa-linux")) | .browser_download_url')"
    # shellcheck disable=SC2164
    pushd /tmp/exa
    unzip -d . exa.zip
    sudo mv exa-linux-x86_64 /usr/bin/exa
    # shellcheck disable=SC2164
    popd
    rm -rf /tmp/exa
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
    sudo pacman -S cmake python clang go tmux ctags ncurses nodejs diff-so-fancy exa ripgrep bat prettyping
  fi
fi

echo "Installing vim plugins"
nvim +'PlugInstall --sync' +qall >/dev/null

echo "Installing jshint jshint jslint jsonlint tidy-markdown"
$NPM -g install jshint jslint jsonlint tidy-markdown

echo "installing markdown lint"
$GEM install mdl

echo "installing jsyaml"
$NPM -g install js-yaml

go get -u -v golang.org/x/tools/cmd/...

# shellcheck disable=SC2164
cd "${curr_dir}"
echo "Environment has been configured."
