#!/bin/zsh

# set -x 
#
#shellcheck shell=zsh

setopt nocorrectall

# Path to your oh-my-zsh configuration.
#tabs -2
# export ZSH=$HOME/.oh-my-zsh
export SHELL="${SHELL-/bin/zsh}"
export OS="${OS-$(uname)}"
export COLORTERM=truecolor
export TERM="xterm-256color"
# export TERM="xterm-direct"

zmodload zsh/terminfo


if [ "$OS" = 'Linux' ]; then 
  export $(run-parts /usr/lib/systemd/user-environment-generators | xargs)
fi

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

fpath+=("/usr/local/share/zsh/site-functions")

if [ "$OS" = 'Linux' ]; then
  export ZSH_CACHE_DIR="${XDG_CACHE_HOME-"$HOME/.cache"}/zsh"
  fpath+=("$HOME/.local/share/zsh/site-functions")
fi
if [ "$OS" = 'Darwin' ]; then
  export ZSH_CACHE_DIR="$HOME/Library/Caches/antidote"
  export PATH="/opt/homebrew/bin:$PATH"
  fpath+=("$ZSH_CACHE_DIR/completions")
fi

# autoload -Uz compinit
# for dump in ~/.zcompdump(N.mh+24); do
#   compinit
# done
# compinit -C

# Customize to your needs...
export LANG="en_US.utf-8"
export JAVA_OPTS="-Dfile.encoding=UTF-8"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export CLICOLOR=1
export VISUAL='code -w'
export EDITOR=$VISUAL


export PATH="$HOME/.rbenv/bin:$HOME/.go/bin:$PATH"
if [ $commands[go] ]; then
  export PATH="${${GOPATH-$HOME/go}//://bin:}/bin:$(go env GOROOT)/bin:$PATH"
fi
export PATH="$HOME/bin:$PATH"
export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

#alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
#alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'

#
# added by travis gem
#[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

if [ $commands[hub] ]; then
  eval "$(hub alias -s)"
fi
#if [ $commands[skaffold] ]; then
#  source <(skaffold completion zsh)
#fi
#if [ $commands[kops] ]; then
#  source <(kops completion zsh)
#fi
#if [ $commands[kind] ]; then
#  source <(kind completion zsh)
#fi
if [ $commands[kubebuilder] ]; then
  source <(kubebuilder completion zsh)
fi
if [  $commands[nvim] ]; then
  export NVIM_LISTEN_ADDRESS=/tmp/neovim/neovim
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ $commands[bat] ]; then
  #export BAT_THEME="1337"
  #export BAT_THEME="DarkNeon"
  #export BAT_THEME='Coldark-Dark'
  #export BAT_THEME='Visual Studio Dark+'
  export BAT_THEME='Catppuccin-mocha'
  #alias cat="bat --plain"
  cat() { bat --paging never --plain --plain "$@" }
fi

if [ $commands[prettyping] ]; then
  alias ping='prettyping --nolegend'
fi

#if [ $commands[gotop] ]; then
#  alias gotop='gotop -c monokai -p'
#fi

if [ $commands[gdu] ]; then
  alias du='gdu -n'
fi

if [ $commands[duf] ]; then
  alias df='duf'
fi

# infocmp $TERM | sed 's/kbs=^[hH]/kbs=\177/' > $TERM.ti
# tic $TERM.ti
# alias tf=terraform

# complete -o nospace -C /usr/local/bin/mc mc

# unalias dcl
# dcl(){ 
#   git clone "${PWD##*/}/$*" 
# }

export PATH="$HOME/.cargo/bin:$PATH"
export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_DEFAULT_OPTS="--ansi"

export nflx_registries=( us-east-1.streamingtest eu-west-1.streamingtest us-west-2.streamingtest )

export DOCKER_BUILDKIT=1

function awscreds {
    if [[ $# -ne 1 ]]; then
        echo "usage: awscreds [list|ROLENAME]"
    else
        if [[ "$1" == "list" ]]; then
            newt --app-type awscreds roles
        else
            newt --app-type awscreds refresh -r $1 $1
        fi
    fi
}

alias roles="newt --app-type awscreds roles"
alias assume="newt --app-type awscreds refresh -r"
export METATRON_USER="iportocarrero@netflix.com"

ghcl() {
  clurl="$1"
	lpath="$HOME/github"
	if [[ ${#${1//[^\/]}} -gt 1 ]]
	then
		lpath="${lpath}/$(echo $1 | cut -d '/' -f 4)/$(echo "$1" | cut -d '/' -f 5 | cut -d '.' -f 1)"
	else
		lpath="${lpath}/$(echo $1 | cut -d '/' -f 1)/$(echo "$1" | cut -d '/' -f 2 | cut -d '.' -f 1)"
		clurl="https://github.com/$1"
	fi

  # lpath="$HOME/github/$(echo $1 | cut -d '/' -f 4)/$(echo "$1" | cut -d '/' -f 5 | cut -d '.' -f 1)"
  git clone "$clurl" "$lpath"
  cd $lpath
}

stcl () {
	clurl="$1"
	lpath="$HOME/nflx"
	if [[ ${#${1//[^\/]}} -gt 1 ]]
	then
		lpath="${lpath}/$(echo $1 | cut -d '/' -f 4)/$(echo "$1" | cut -d '/' -f 5 | cut -d '.' -f 1)"
	else
		lpath="${lpath}/$(echo $1 | cut -d '/' -f 1)/$(echo "$1" | cut -d '/' -f 2 | cut -d '.' -f 1)"
		clurl="https://stash.corp.netflix.com/scm/$1"
	fi
	hub clone "$clurl" "$lpath"
	cd $lpath
}

goheapprof() { 
  go tool pprof -http=:7142 http://$1:7001/debug/pprof/heap 
}

gocpuprof() { 
  go tool pprof -http=:7136 http://$1:7001/debug/pprof/profile 
}

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

jwtdecode() {
    if [ $# -eq 0 ]
      then
        jwt=$(wl-paste)
      else
        jwt=$1
    fi
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$jwt"
}

export MANPAGER="sh -c 'col -bx | bat -l man -p'" MANROFFOPT='-c'


#if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
if [ -e $HOME/.sdkman/bin/sdkman-init.sh ]; then . $HOME/.sdkman/bin/sdkman-init.sh; fi # added by sdkman installer

#export BAT_THEME="Catppuccin-mocha"

# [ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

autoload -Uz compinit && compinit -i

# alias k=kubectl
export GITHUB_USER=casualjim
#export BAT_THEME="Visual Studio Dark+"

export NVM_DIR="$HOME/.nvm"
export PATH="${PATH}:${HOME}/.krew/bin"
[[ ":$PATH:" != *":$HOME/.kube/bin:"* ]] && export PATH="$HOME/.kube/bin:${PATH}"

export KUBECACHEDIR=~/Library/Caches/kubectl


if [ $commands[starship] ]; then
  eval "$(starship init zsh)"
fi

if [[ -f /usr/share/zsh-antidote/antidote.zsh ]]; then
  source '/usr/share/zsh-antidote/antidote.zsh'
  antidote load
elif [[ -f "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
  antidote load
fi
[[ -f ~/.zsh_plugins.zsh ]] && source ~/.zsh_plugins.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# eval $(grc-rs --aliases)
[[ -s /opt/homebrew/etc/grc.zsh ]] && source /opt/homebrew/etc/grc.zsh


if [ $commands[newt] ]; then
  eval "$(NEWT_OFFLINE=1 NEWT_QUIET=1 newt --completion-script-zsh)"
fi

if [ $commands[eza] ]; then
  alias l='eza -lh --git'
  alias la='eza -lah --git'
  alias ll='eza -lh --git'
  alias ls='eza -G'
  alias lsa='eza -lah --git'
  alias tree='eza --tree'
fi

alias ktest="kubectl --context infraapi-test"
alias kprod="kubectl --context infraapi-prod"
alias humanlog='humanlog --skip-unchanged=false --truncate=false'
