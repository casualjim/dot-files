FROM golang:1.10-alpine

RUN apk add --no-cache go musl-dev git bash upx &&\
  go get -d github.com/github/hub &&\
  cd /go/src/github.com/github/hub &&\
  script/build

RUN upx /go/src/github.com/github/hub/bin/hub

FROM alpine

COPY --from=0 /go/src/github.com/github/hub/bin/hub /usr/bin/hub
RUN set -e &&\
  apk add --no-cache zsh zsh-vcs git sudo shadow vim curl tar gzip ctags ncurses jq bash tini mailcap tzdata ca-certificates &&\
  curl -o /usr/bin/direnv -L'#' https://github.com/direnv/direnv/releases/download/v2.15.2/direnv.linux-amd64 &&\
  chmod +x /usr/bin/direnv &&\
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
