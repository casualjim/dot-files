FROM debian:testing-slim

ENV DEBIAN_FRONTEND noninteractive
ARG username=eng

RUN echo "deb http://deb.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list &&\ 
  apt-get update &&\
  apt-get install -y apt-transport-https zsh git sudo gnupg curl pv httpie vim-nox zsh cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term direnv ruby jq git-hub &&\
  curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list &&\
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list &&\
  apt-get update &&\
  apt-get install -y nodejs build-essential yarn kubectl &&\
  npm install -g diff-so-fancy jshint jslint jsonlint tidy-markdown js-yaml &&\
  curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash &&\
  useradd -m -s /bin/zsh ${username} &&\
  mkdir -p /etc/sudoers.d &&\
  echo "${username} ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/${username} &&\
  echo 'wheel ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel &&\
  chmod 0400 /etc/sudoers.d/${username} /etc/sudoers.d/wheel &&\
  echo "deb http://ppa.launchpad.net/gophers/archive/ubuntu bionic main" > /etc/apt/sources.list.d/gophers.list &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C73998DC9DFEA6DCF1241057308C15A29AD198E9 &&\
  apt-get update &&\
  apt-get install -yqq golang-1.10-go &&\
  echo 'Cleaning up' && \
  apt-get autoremove -yqq &&\
  apt-get clean -y &&\
  apt-get autoclean -yqq &&\
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

USER ${username}
ADD zshrc /home/${username}/.zshrc
WORKDIR /home/${username}

RUN \
  echo 'Updating apt' && \
  sudo apt-get update -qq && \
  sudo chown ${username} /home/${username}/.zshrc &&\
  sed -i 's/backchat/backchat-remote/g' /home/${username}/.zshrc &&\
  zsh -c "source /home/${username}/.zshrc" &&\
  echo 'Running env setup script' && \
  echo 'Cleaning up' && \
  sudo apt-get autoremove -yqq &&\
  sudo apt-get clean -y &&\
  sudo apt-get autoclean -yqq &&\
  sudo rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

ENV PATH "/usr/lib/go-1.10/bin:$PATH"

SHELL [ "/bin/zsh", "-c" ]
CMD ["zsh"]