FROM debian:9-slim

RUN set -e &&\
  apt-get update &&\
  apt-get install -yqq \
    curl \
    vim-tiny \
    python-dev \
    ncurses-term \
    direnv \
    jq \
    zsh \
    git \
    sudo \
    tar \
    gzip \
    git-hub &&\
  useradd -m -s /bin/zsh ivan &&\
  mkdir -p /etc/sudoers.d &&\
  echo "ivan ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/ivan &&\
  echo 'wheel ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel &&\
  chmod 0400 /etc/sudoers.d/ivan /etc/sudoers.d/wheel &&\
  apt-get autoremove -yqq &&\
  apt-get clean -y &&\
  apt-get autoclean -yqq &&\
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

USER ivan
ADD --chown=ivan zshrc /home/ivan/.zshrc
WORKDIR /home/ivan

RUN \
  zsh -c "source /home/ivan/.zshrc"

SHELL [ "/bin/zsh", "-c" ]
CMD ["zsh"]
