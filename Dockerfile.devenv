FROM debian:testing-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq &&\
  apt-get install -yqq git build-essential &&\
  git clone https://github.com/ncopa/su-exec /usr/src/su-exec &&\
  cd /usr/src/su-exec &&\
  LDFLAGS="-s -w" make su-exec-static &&\
  git clone https://github.com/Yelp/dumb-init /usr/src/dumb-init &&\
  cd /usr/src/dumb-init &&\
  make 
  
FROM debian:testing-slim

ENV DEBIAN_FRONTEND noninteractive

COPY --from=0 /usr/src/su-exec/su-exec-static /usr/bin/su-exec
COPY --from=0 /usr/src/dumb-init/dumb-init /usr/bin/dumb-init

RUN echo "deb http://deb.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list &&\ 
  apt-get update &&\
  apt-get install -y apt-transport-https zsh git sudo gnupg curl pv httpie vim-nox zsh cmake python-dev python-pip clang libclang-dev tmux exuberant-ctags ncurses-term direnv ruby jq git-hub &&\
  curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list &&\
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list &&\
  apt-get update &&\
  apt-get install -y nodejs build-essential yarn kubectl &&\
  npm install -g diff-so-fancy jshint jslint jsonlint tidy-markdown js-yaml &&\
  curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash &&\
  useradd -m -s /bin/zsh ivan &&\
  mkdir -p /etc/sudoers.d &&\
  echo "ivan ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/ivan &&\
  echo 'wheel ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel &&\
  chmod 0400 /etc/sudoers.d/ivan /etc/sudoers.d/wheel &&\
  echo "deb http://ppa.launchpad.net/gophers/archive/ubuntu bionic main" > /etc/apt/sources.list.d/gophers.list &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C73998DC9DFEA6DCF1241057308C15A29AD198E9 &&\
  apt-get update &&\
  apt-get install -yqq golang-1.10-go &&\
  echo 'Cleaning up' && \
  apt-get autoremove -yqq &&\
  apt-get clean -y &&\
  apt-get autoclean -yqq &&\
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

ENV PATH "/usr/lib/go-1.10/bin:$PATH"

USER ivan
ADD --chown=ivan zshrc /home/ivan/.zshrc
ADD --chown=ivan gitconfig /home/ivan/.gitconfig
ADD --chown=ivan ctags /home/ivan/.ctags
ADD --chown=ivan vimreboot /home/ivan/.vim
WORKDIR /home/ivan

RUN \
  echo 'Updating apt' &&\  
  sudo apt-get update -qq && \
  sed -i 's/backchat/backchat-remote/g' /home/ivan/.zshrc &&\
  ln -sf /home/ivan/.vim/init.vim /home/ivan/.vimrc &&\
  zsh -c "source /home/ivan/.zshrc" &&\
  echo "Installing Vim Plugins" &&\
  script -qfc "vim -e +qall" /dev/null > /dev/null &&\
  echo "Installing YouCompleteMe" &&\
  cd ~/.vim/bundle/YouCompleteMe &&\
  ./install.py --clang-completer --gocode-completer --js-completer &&\
  echo 'Cleaning up' && \
  sudo apt-get autoremove -yqq &&\
  sudo apt-get clean -y &&\
  sudo apt-get autoclean -yqq &&\
  sudo rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

ENV GOPATH "/home/ivan/go"
ENV PATH "$GOPATH/bin:$PATH"
SHELL [ "/bin/zsh", "-c" ]
ENTRYPOINT [ "/usr/bin/dumb-init" ]
CMD ["zsh"]