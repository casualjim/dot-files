FROM golang:1.4
MAINTAINER Ivan Porto Carrero

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update -qq && \
  apt-get install -yqq curl httpie vim-nox zsh python-dev tmux exuberant-ctags ncurses-term nodejs npm cmake && \
  git clone --recursive https://github.com/casualjim/dot-files /root/dot-files && \
  ln -sf /root/dot-files/vimreboot ~/.vim && \
  ln -sf /root/dot-files/vimreboot/vimrc ~/.vimrc && \
  ln -sf /root/dot-files/ctags ~/.ctags && \
  ln -sf /root/dot-files/antigen ~/.antigen && \
  cp /root/dot-files/zshrc ~/.zshrc && \
  ln -sf /root/dot-files/.tmux.conf ~/.tmux.conf && \
  ln -sf /root/dot-files/gitconfig ~/.gitconfig && \
  vim -e -c BundleInstall -c qall > /dev/null && \
  cd ~/.vim/bundle/YouCompleteMe && \
  ./install.sh --clang-completer && \
  cd ~/.vim/bundle/tern_for_vim && \
  npm install && \
  apt-get clean -q && \
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* 

