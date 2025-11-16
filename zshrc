#!/bin/zsh

#set -x
#
#shellcheck shell=bash

# ============================================================================
# Initial Setup
# ============================================================================

export SHELL="${SHELL-/bin/zsh}"
export OS="${OS-$(uname)}"
export COLORTERM=truecolor
export TERM="xterm-256color"

zmodload zsh/terminfo

# ============================================================================
# Environment Detection and Setup
# ============================================================================

if [ "$OS" = 'Linux' ]; then 
  export "$(run-parts /usr/lib/systemd/user-environment-generators | xargs)"
fi

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ============================================================================
# Base Environment Variables
# ============================================================================

export LANG="en_US.utf-8"
export JAVA_OPTS="-Dfile.encoding=UTF-8"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export CLICOLOR=1
export VISUAL='code -w'
export EDITOR="$VISUAL"
export GITHUB_USER=casualjim

# ============================================================================
# Path Configuration
# ============================================================================

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$HOME/.go/bin:$PATH"

if [ "${commands[go]}" ]; then
  GOROOT="$(go env GOROOT)"
  GOPATH_BIN="${GOPATH:-$HOME/go}"
  GOPATH_BIN="${GOPATH_BIN//://bin:}/bin"
  export PATH="${GOPATH_BIN}:${GOROOT}/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"

if [ "$OS" = 'Darwin' ]; then
  export PATH="/etc/profiles/per-user/ivan/bin:/opt/homebrew/bin:$PATH"
fi

# ============================================================================
# Completion System Configuration
# ============================================================================

fpath+=("/usr/local/share/zsh/site-functions")

if [ "$OS" = 'Linux' ]; then
  export ZSH_CACHE_DIR="${XDG_CACHE_HOME-"$HOME/.cache"}/zsh"
  fpath+=("$HOME/.local/share/zsh/site-functions")
fi

if [ "$OS" = 'Darwin' ]; then
  export ZSH_CACHE_DIR="$HOME/Library/Caches/antidote"
  fpath+=("$ZSH_CACHE_DIR/completions")
fi

autoload -Uz compinit && compinit -i

# ============================================================================
# Zstyle Configuration
# ============================================================================

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# shellcheck disable=SC2296
# zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# FZF configuration via zstyle
zstyle ':fzf-tab:*' fzf-flags --ansi
# shellcheck disable=SC2016
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always "$realpath"'
# shellcheck disable=SC2016
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always "$realpath"'

# Plugin-specific zstyle configurations
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'color-scale' all
# zstyle ':omz:plugins:eza' 'color-scale-mode' gradient
zstyle ':omz:plugins:eza' 'color-scale-mode' fixed

# ============================================================================
# FZF Configuration
# ============================================================================

export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_DEFAULT_OPTS="--ansi"

# ============================================================================
# Tool-specific Environment Variables
# ============================================================================

export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"
export KUBECACHEDIR="$HOME/Library/Caches/kubectl"

# Bat configuration (OMZ bat plugin will handle aliases)
export BAT_THEME='Catppuccin-mocha'
export MANPAGER="sh -c 'col -bx | bat -l man -p'" MANROFFOPT='-c'

# Kubernetes path
[[ ":$PATH:" != *":$HOME/.krew/bin:"* ]] && export PATH="$HOME/.krew/bin:${PATH}"
[[ ":$PATH:" != *":$HOME/.kube/bin:"* ]] && export PATH="$HOME/.kube/bin:${PATH}"

# ============================================================================
# Load Antidote Plugin Manager
# ============================================================================

if [[ -f /usr/share/zsh-antidote/antidote.zsh ]]; then
  source '/usr/share/zsh-antidote/antidote.zsh'
  antidote load
elif [[ -f "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
  antidote load
fi

[[ -f "$HOME/.zsh_plugins.zsh" ]] && source "$HOME/.zsh_plugins.zsh"

# ============================================================================
# Plugin Post-configuration
# ============================================================================

# Remove unwanted git plugin aliases
for todisable in gup gupv gupa gupav gupom gupomi; do
  unalias $todisable 2>/dev/null
done

# History substring search keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ============================================================================
# Custom Functions
# ============================================================================


# Clone GitHub repositories to ~/github
ghcl() {
  clurl="$1"
	lpath="$HOME/github"
	if [[ ${#${1//[^\/]}} -gt 1 ]]
	then
		lpath="${lpath}/$(echo "$1" | cut -d '/' -f 4)/$(echo "$1" | cut -d '/' -f 5 | cut -d '.' -f 1)"
	else
		lpath="${lpath}/$(echo "$1" | cut -d '/' -f 1)/$(echo "$1" | cut -d '/' -f 2 | cut -d '.' -f 1)"
		clurl="https://github.com/$1"
	fi

  git clone "$clurl" "$lpath"
  cd "$lpath" || return
}

# Clone Wagyu repositories to ~/wagyu
wcl() {
  clurl="$1"
	lpath="$HOME/wagyu"
	if [[ ${#${1//[^\/]}} -gt 1 ]]
	then
		lpath="${lpath}/$(echo "$1" | cut -d '/' -f 4)/$(echo "$1" | cut -d '/' -f 5 | cut -d '.' -f 1)"
	else
		lpath="${lpath}/$(echo "$1" | cut -d '/' -f 1)/$(echo "$1" | cut -d '/' -f 2 | cut -d '.' -f 1)"
		clurl="https://git.wagyu.icu/$1"
	fi

  git clone "$clurl" "$lpath"
  cd "$lpath" || return
}

# Go profiling helpers
goheapprof() { 
  go tool pprof -http=:7142 "http://$1:7001/debug/pprof/heap"
}

gocpuprof() { 
  go tool pprof -http=:7136 "http://$1:7001/debug/pprof/profile"
}

# JWT decode helper
jwtdecode() {
    if [ $# -eq 0 ]
      then
        jwt="$(wl-paste)"
      else
        jwt="$1"
    fi
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$jwt"
}

# Yazi file manager integration
function y() {
  local tmp
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || exit 1
  rm -f -- "$tmp"
}

# ============================================================================
# Additional Tool Integrations
# ============================================================================

# Hub (Git wrapper) - gh plugin handles this now, but keep for backwards compat
if [ "${commands[hub]}" ]; then
  eval "$(hub alias -s)"
fi

# ============================================================================
# Custom Aliases (those not provided by OMZ plugins)
# ============================================================================

# bat - better cat
if [ "${commands[bat]}" ]; then
  alias cat='bat --paging never --plain --plain'
fi


# Additional utility aliases
if [ "${commands[prettyping]}" ]; then
  alias ping='prettyping --nolegend'
fi

if [ "${commands[nping]}" ]; then
  alias ping='nping'
fi

if [ "${commands[gdu]}" ]; then
  alias du='gdu -n'
fi


if [ "${commands[dust]}" ]; then
  alias du='dust'
fi

if [ "${commands[duf]}" ]; then
  alias df='duf'
fi

alias humanlog='humanlog --skip-unchanged=false --truncate=false'

# ============================================================================
# Final Integrations
# ============================================================================

# FZF integration
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# Local customizations
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

# ============================================================================
# McFly - Must be at the very end
# ============================================================================

eval "$(mcfly init zsh)"

# ============================================================================
# Shell Options - Must be dead last
# ============================================================================

setopt nocorrectall

