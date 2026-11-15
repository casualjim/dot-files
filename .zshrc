
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#
# NOTE: if p10k warns about "console output during zsh initialization", something
# below this block printed output while the shell started (mcfly's first run did).
# We have seen this before and it is otherwise harmless. Either let that tool finish
# its first run once, or move this block below it.
# `quiet` suppresses that warning; it must be set before the block below runs.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#shellcheck shell=zsh

# Environment variables, PATH entries and aliases live in mise, not here:
#   ~/.config/mise/config.toml        shared: [env], _.path, [shell_alias]
#   ~/.config/mise/config.linux.toml  Linux only
# mise is activated by the oh-my-zsh mise plugin (see ~/.zsh_plugins.txt), so they apply
# once that plugin has loaded. What stays below is what must exist before that point, or
# belongs to this shell session.

export SHELL="${SHELL-/bin/zsh}"
export OS="${OS-$(uname)}"
export TERM="xterm-256color"

zmodload zsh/terminfo

export HISTSIZE=200000
export SAVEHIST=200000
export HISTFILE=~/.zsh_history

setopt EXTENDED_HISTORY

fpath+=("/usr/local/share/zsh/site-functions")

if [ "$OS" = 'Linux' ]; then
  export ZSH_CACHE_DIR="${XDG_CACHE_HOME-"$HOME/.cache"}/zsh"
  fpath+=("$HOME/.local/share/zsh/site-functions")
fi
if [ "$OS" = 'Darwin' ]; then
  export ZSH_CACHE_DIR="$HOME/Library/Caches/antidote"
  # Homebrew provides mise itself, so this has to be on PATH before mise can activate.
  export PATH="/etc/profiles/per-user/ivan/bin:/opt/homebrew/bin:$PATH"
  fpath+=("$ZSH_CACHE_DIR/completions")
fi

if [ $commands[hub] ]; then
  eval "$(hub alias -s)"
fi

if [ $commands[kubebuilder] ]; then
  source <(kubebuilder completion zsh)
fi

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

  git clone "$clurl" "$lpath"
  cd $lpath
}

goheapprof() {
  go tool pprof -http=:7142 http://$1:7001/debug/pprof/heap
}

gocpuprof() {
  go tool pprof -http=:7136 http://$1:7001/debug/pprof/profile
}

jwtdecode() {
    if [ $# -eq 0 ]
      then
        jwt=$(wl-paste)
      else
        jwt=$1
    fi
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$jwt"
}

autoload -Uz compinit && compinit -i

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

if [[ -f /usr/share/zsh-antidote/antidote.zsh ]]; then
  source '/usr/share/zsh-antidote/antidote.zsh'
  antidote load
elif [ $commands[brew] ] && [[ -f "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
  antidote load
fi

[[ -f ~/.zsh_plugins.zsh ]] && source ~/.zsh_plugins.zsh

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^r' history-incremental-search-backward

# After the plugins on purpose: the oh-my-zsh eza plugin defines ls, ll and la, and these
# must win. (mise's [shell_alias] runs earlier, so it cannot hold them.)
if [ $commands[eza] ]; then
  alias l='eza -lh --git --icons --group-directories-first --group --header'
  alias la='eza -lah --git --icons --group-directories-first'
  alias ll='eza -lh --git --icons --group-directories-first'
  alias ls='eza -G --icons --group-directories-first'
  alias lsa='eza -lah --git --icons --group-directories-first'
  alias tree='eza --tree --icons --group-directories-first'
fi

[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

eval "$(mcfly init zsh)"

unset LS_COLORS
setopt nocorrectall

unset ZSH_AUTOSUGGEST_STRATEGY
source /home/ivan/github/casualjim/zage/src/shell_integration/zsh.zsh

export GPG_TTY=$(tty)

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
