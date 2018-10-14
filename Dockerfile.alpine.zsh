FROM golang:alpine

RUN apk add --no-cache go musl-dev git bash upx &&\
  go get -d github.com/github/hub &&\
  cd /go/src/github.com/github/hub &&\
  script/build

RUN upx /go/src/github.com/github/hub/bin/hub

FROM alpine

COPY --from=0 /go/src/github.com/github/hub/bin/hub /usr/bin/hub
RUN set -e &&\
  apk add --no-cache zsh zsh-vcs git sudo shadow vim curl tar gzip ctags ncurses jq bash tini mailcap tzdata ca-certificates tar gzip postgresql-client redis &&\
  curl -o /usr/bin/direnv -L'#' https://github.com/direnv/direnv/releases/download/v2.15.2/direnv.linux-amd64 &&\
  chmod +x /usr/bin/direnv &&\
  mkdir -p /tmp/bat &&\
  curl -sL $(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | contains("x86_64-unknown-linux-musl.tar.gz") and contains("bat-")) | .browser_download_url') | tar -C /tmp/bat --strip-components 1 -xz &&\
  mv /tmp/bat/bat /usr/bin/bat &&\
  rm -rf /tmp/bat &&\
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
ENTRYPOINT [ "/sbin/tini", "--" ]
CMD ["zsh"]
