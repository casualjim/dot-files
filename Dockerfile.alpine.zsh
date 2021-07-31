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
  apk add --no-cache zsh zsh-vcs git sudo shadow vim curl tar unzip gzip ctags ncurses jq bash mailcap tzdata ca-certificates postgresql-client redis sed grep bind-tools exa bat starship &&\
  curl -sfL git.io/antibody | sh -s - -b /usr/local/bin &&\
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
