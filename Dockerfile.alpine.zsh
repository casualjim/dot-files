FROM golang:alpine

RUN apk add --no-cache musl-dev git bash upx

RUN mkdir -p /hubfiles && git clone \
  --config transfer.fsckobjects=false \
  --config receive.fsckobjects=false \
  --config fetch.fsckobjects=false \
  --depth 1 \
  https://github.com/github/hub.git /usr/src/hub

WORKDIR /usr/src/hub

RUN script/build -o /hubfiles/hub

RUN upx /hubfiles/hub

FROM alpine

COPY --from=0 /hubfiles/hub /usr/bin/hub
RUN set -e &&\
  apk add --no-cache zsh zsh-vcs git sudo shadow vim curl tar unzip gzip ctags ncurses jq bash mailcap tzdata ca-certificates postgresql-client redis sed grep &&\
  curl -fsSL https://starship.rs/install.sh | bash -s -- -y &&\
  curl -o /usr/bin/direnv -L'#' $(curl -s https://api.github.com/repos/direnv/direnv/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url') &&\
  chmod +x /usr/bin/direnv &&\
  mkdir -p /tmp/bat &&\
  curl -sL $(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | contains("x86_64-unknown-linux-musl.tar.gz") and contains("bat-")) | .browser_download_url') | tar -C /tmp/bat --strip-components 1 -xz &&\
  mv /tmp/bat/bat /usr/bin/bat &&\
  rm -rf /tmp/bat &&\
  mkdir -p /tmp/exa &&\
  curl -o /tmp/exa/exa.zip -L $(curl -s https://api.github.com/repos/ogham/exa/releases/latest | jq -r '.assets[] | select(.name | contains("exa-linux")) | .browser_download_url') &&\
  cd /tmp/exa &&\
  unzip -d . exa.zip &&\
  mv exa-linux-x86_64 /usr/bin/exa &&\
  cd / &&\
  rm -rf /tmp/exa &&\
  useradd -m -s /bin/zsh ivan &&\
  mkdir -p /etc/sudoers.d &&\
  echo "ivan ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/ivan &&\
  echo 'wheel ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel &&\
  chmod 0400 /etc/sudoers.d/ivan /etc/sudoers.d/wheel

USER ivan
ADD --chown=ivan zshrc /home/ivan/.zshrc
WORKDIR /home/ivan

RUN \
  zsh -c "source /home/ivan/.zshrc"

SHELL [ "/bin/zsh", "-c" ]
CMD ["zsh"]
