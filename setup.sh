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
script -qfc "vim -e +qall" /dev/null > /dev/null

echo "Installing YouCompleteMe dependencies"
if [ `uname` = 'Darwin' ]; then
  brew install cmake nodejs direnv hub
fi
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "${ID_LIKE-$ID}" = "debian" ]; then
    echo "Installing for debian"
    sudo apt-get install -y curl httpie vim-nox zsh cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term nodejs npm direnv ruby
    sudo ln -sf /usr/bin/nodejs /usr/bin/node
    curl -L'#' https://godeb.s3.amazonaws.com/godeb-amd64.tar.gz | pv | sudo tar -C /usr/local/bin -zx
    sudo godeb install
    GH_HUB_VERSION=2.2.1
    curl -L'#' "https://github.com/github/hub/releases/download/v$GH_HUB_VERSION/hub-linux-amd64-$GH_HUB_VERSION.tar.gz" | tar -C /tmp && \
    cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/hub" /usr/bin && \
    chmod +x "/usr/bin/hub" && \
    cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/man/hub.1" /usr/share/man/man1 && \
    mandb && \
    cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/etc/hub/hub.bash_completion.sh" /usr/share/bash-completion/completions/hub && \
    cp "/tmp/linux-hub-amd64-$GH_HUB_VERSION/etc/hub.zsh_completion" /usr/share/zsh/vendor-completions/_hub
  fi
  if [ "${ID}" = "arch" ]; then
    echo "Installing for arch"
    sudo pacman -S cmake python clang go tmux ctags ncurses nodejs
  fi
fi

echo "Installing jshint"
npm -g install jshint jslint

echo "installing jsonlint"
npm -g install jsonlint

echo "installing markdown lint"
gem install mdl

echo "installing jsyaml"
npm -g install js-yaml

# echo "Installing jsbeautify"
# cd ~/.vim/bundle/js-beautify
# git submodule update --init --recursive

echo "Installing YouCompleteMe"
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer --gocode-completer

go get -u -v github.com/golang/lint/golint
go get -u -v golang.org/x/tools/cmd/...
go get -u -v github.com/tools/godep
go get -u -v github.com/jteeuwen/go-bindata/...
go get -u -v github.com/elazarl/go-bindata-assetfs/...
go get -u -v github.com/redefiance/go-find-references
go get -u -v github.com/sqs/goreturns
go get -u -v code.google.com/p/gomock/gomock
go get -u -v code.google.com/p/gomock/mockgen
go get -u -v github.com/axw/gocov/gocov
go get -u -v gopkg.in/matm/v1/gocov-html
go get -u -v github.com/AlekSi/gocov-xml
go get -u -v github.com/nsf/gocode
go get -u -v github.com/kisielk/errcheck
go get -u -v github.com/jstemmer/gotags
go get -u -v github.com/smartystreets/goconvey
go get -u -v github.com/rogpeppe/godef
go get -u -v github.com/pquerna/ffjson
go get -u -v github.com/clipperhouse/gen

cd ${curr_dir}
echo "Environment has been configured."
