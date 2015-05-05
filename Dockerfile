FROM golang:1.4
MAINTAINER Ivan Porto Carrero

ENV DEBIAN_FRONTEND noninteractive

RUN \
  echo 'Updating apt' && \
  apt-get update -qq && \
  echo 'Downloading debs' && \
  apt-get install -yqq curl httpie vim-nox zsh python-dev tmux exuberant-ctags ncurses-term nodejs npm cmake && \
  echo 'Linking files' && \
  git clone --recursive https://github.com/casualjim/dot-files /root/dot-files && \
  echo 'Linking files' && \
  ln -sf /root/dot-files/vimreboot ~/.vim && \
  ln -sf /root/dot-files/vimreboot/vimrc ~/.vimrc && \
  ln -sf /root/dot-files/ctags ~/.ctags && \
  ln -sf /root/dot-files/antigen ~/.antigen && \
  cp /root/dot-files/zshrc ~/.zshrc && \
  ln -sf /root/dot-files/.tmux.conf ~/.tmux.conf && \
  ln -sf /root/dot-files/gitconfig ~/.gitconfig && \
  echo 'Installing go dev tools' && \
  go get github.com/constabulary/gb/... && \
  go get -u -v github.com/golang/lint/golint && \
  go get -u -v golang.org/x/tools/cmd/... && \
  go get -u -v github.com/tools/godep && \
  go get -u -v github.com/jteeuwen/go-bindata/... && \
  go get -u -v github.com/elazarl/go-bindata-assetfs/... && \
  go get -u -v github.com/redefiance/go-find-references && \
  go get -u -v github.com/sqs/goreturns && \
  go get -u -v code.google.com/p/gomock/gomock && \
  go get -u -v code.google.com/p/gomock/mockgen && \
  go get -u -v github.com/axw/gocov/gocov && \
  go get -u -v gopkg.in/matm/v1/gocov-html && \
  go get -u -v github.com/AlekSi/gocov-xml && \
  go get -u -v github.com/nsf/gocode && \
  go get -u -v github.com/kisielk/errcheck && \
  go get -u -v github.com/jstemmer/gotags && \
  go get -u -v github.com/smartystreets/goconvey && \
  go get -u -v github.com/rogpeppe/godef && \
  go get -u -v github.com/pquerna/ffjson && \
  go get -u -v github.com/clipperhouse/gen && \
  echo 'Installing linters' && \
  gem install mdl && \
  npm -g install jshint jslint jsonlint js-yaml && \
  cd ~/.vim/bundle/YouCompleteMe && \
  ./install.sh --clang-completer --gocode-completer && \
  cd ~/.vim/bundle/tern_for_vim && \
  npm install && \
  echo 'Cleaning up' && \
  apt-get clean -q && \
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/*
