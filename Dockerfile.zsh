FROM golang

RUN apt-get update && apt-get install -yqq groff bsdmainutils
RUN mkdir -p /hubfiles && git clone \
  --config transfer.fsckobjects=false \
  --config receive.fsckobjects=false \
  --config fetch.fsckobjects=false \
  https://github.com/github/hub.git /usr/src/hub

WORKDIR /usr/src/hub

RUN script/build -o /hubfiles/hub

FROM debian:testing

RUN mkdir -p /target
COPY --from=0 /hubfiles/hub /usr/bin/hub

RUN set -e &&\
  apt-get update -qq &&\
  apt-get install -yqq \
    curl \
    gawk \
    vim-tiny \
    python3-dev \
    ncurses-term \
    direnv \
    locales \
    fonts-powerline \
    unzip \
    jq \
    zsh \
    git \
    sudo \
    tar \
    gzip \
    gnupg \
    iputils-ping &&\
  echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen &&\
  locale-gen &&\
  useradd -m -s /bin/zsh ivan &&\
  mkdir -p /etc/sudoers.d &&\
  echo "ivan ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/ivan &&\
  echo 'wheel ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel &&\
  chmod 0400 /etc/sudoers.d/ivan /etc/sudoers.d/wheel &&\
  curl -fsSL https://starship.rs/install.sh | bash -s -- -y &&\
  curl -o /usr/bin/prettyping -L https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping &&\
  chmod +x /usr/bin/prettyping &&\
  curl -o /tmp/bat.deb -L $(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | contains("amd64.deb") and contains("bat_")) | .browser_download_url') &&\
  dpkg -i /tmp/bat.deb &&\
  mkdir -p /tmp/exa &&\
  curl -o /tmp/exa/exa.zip -L $(curl -s https://api.github.com/repos/ogham/exa/releases/latest | jq -r '.assets[] | select(.name | contains("exa-linux")) | .browser_download_url') &&\
  cd /tmp/exa &&\
  unzip -d . exa.zip &&\
  mv exa-linux-x86_64 /usr/bin/exa &&\
  cd / &&\
  rm -rf /tmp/exa &&\
  apt-get autoremove -yqq &&\
  apt-get clean -y &&\
  apt-get autoclean -yqq &&\
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc/* /usr/share/locale/* /var/cache/debconf/*-old

ENV LANG en_US.UTF-8

USER ivan
ADD --chown=ivan zshrc /home/ivan/.zshrc
WORKDIR /home/ivan

RUN \
  zsh -c "source /home/ivan/.zshrc"

SHELL [ "/bin/zsh", "-c" ]
CMD ["zsh"]
