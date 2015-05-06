FROM golang:1.4
MAINTAINER Ivan Porto Carrero

ENV DEBIAN_FRONTEND noninteractive

ADD setup.sh /

RUN \
  echo 'Updating apt' && \
  apt-get update -qq && \
  git clone --recursive https://github.com/casualjim/dot-files /root/dot-files && \
  echo 'Running env setup script' && \
  /setup.sh && \
  echo 'Cleaning up' && \
  apt-get clean -q && \
  rm -rf  /tmp/* /var/tmp/* /var/lib/apt/lists/*
