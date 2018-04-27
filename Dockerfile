FROM debian:testing-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update &&\
  apt-get install -y zsh git sudo gnupg curl pv httpie vim-nox zsh cmake python-dev clang libclang-dev tmux exuberant-ctags ncurses-term direnv ruby jq &&\
  curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list &&\
  apt-get update &&\
  apt-get install -y nodejs build-essential yarn &&\
  npm install -g diff-so-fancy jshint jslint jsonlint tidy-markdown js-yaml &&\
  useradd -m -s /bin/zsh eng &&\
  mkdir -p /etc/sudoers.d &&\
  echo 'eng ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/eng &&\
  echo 'wheel ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel &&\
  chmod 0400 /etc/sudoers.d/eng /etc/sudoers.d/wheel &&\
  echo "deb http://ppa.launchpad.net/gophers/archive/ubuntu bionic main" > /etc/apt/sources.list.d/gophers.list &&\
  echo "deb-src http://ppa.launchpad.net/gophers/archive/ubuntu bionic main" >> /etc/apt/sources.list.d/gophers.list &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C73998DC9DFEA6DCF1241057308C15A29AD198E9 &&\
  apt-get update &&\
  apt-get install -yqq golang-1.10-go &&\
  echo 'Cleaning up' && \
  apt-get autoremove -yqq &&\
  apt-get clean -y &&\
  apt-get autoclean -yqq &&\
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

USER eng
WORKDIR /home/eng

RUN \
  echo 'Updating apt' && \
  sudo apt-get update -qq && \
  git clone --recursive https://github.com/casualjim/dot-files /home/eng/dot-files && \
  ln -sf /home/eng/dot-files/zshrc /home/eng/.zshrc &&\
  sed -i 's/backchat/backchat-remote/g' /home/eng/.zshrc &&\
  zsh -c 'source /home/eng/.zshrc' &&\
  echo 'Running env setup script' && \
  # /home/eng/dot-files/setup.sh && \
  echo 'Cleaning up' && \
  sudo apt-get autoremove -yqq &&\
  sudo apt-get clean -y &&\
  sudo apt-get autoclean -yqq &&\
  sudo rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

ENV PATH "/usr/lib/go-1.10/bin:$PATH"

ENTRYPOINT [ "/bin/zsh", "-c" ]
CMD ["zsh"]