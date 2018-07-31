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
    gnupg \
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

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64 /tmp/tini-static-amd64
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64.asc /tmp/tini-static-amd64.asc

# try a few keyservers, sometimes they fail
RUN for key in \
      595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    ; do \
      gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" || \
      gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
    done \
    &&\
    gpg --verify /tmp/tini-static-amd64.asc &&\
    install -m 0755 /tmp/tini-static-amd64 /bin/tini

USER ivan
ADD --chown=ivan zshrc /home/ivan/.zshrc
WORKDIR /home/ivan

RUN \
  zsh -c "source /home/ivan/.zshrc"

SHELL [ "/bin/zsh", "-c" ]
ENTRYPOINT [ "/bin/tini", "--" ]
CMD ["zsh"]
