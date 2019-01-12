#!/bin/sh

mkdir -p $HOME/github/casualjim/dot-files
git clone --recursive https://github.com/casualjim/dot-files $HOME/github/casualjim/dot-files
cd $HOME/github/casualjim/dot-files
./setup.sh
