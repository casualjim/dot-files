FROM golang:1.10-alpine

RUN apk add --no-cache go musl-dev git bash &&\
  mkdir -p /usr/src &&\
  cd /usr/src &&\
  git clone https://github.com/github/hub.git &&\
  cd hub &&\
  script/build

FROM alpine

COPY --from=0 /usr/src/hub/bin/hub /usr/bin/hub
RUN set -e &&\
  apk add --no-cache zsh zsh-vcs git sudo shadow vim curl tar gzip ctags ncurses jq bash &&\
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
