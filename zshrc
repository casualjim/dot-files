#!/bin/zsh

#
#shellcheck shell=bash

# Path to your oh-my-zsh configuration.
#tabs -2
# export ZSH=$HOME/.oh-my-zsh
export SHELL="${SHELL-/bin/zsh}"
export OS="${OS-$(uname)}"
export COLORTERM=truecolor
export TERM="xterm-256color"

zmodload zsh/terminfo

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

fpath+=("/usr/local/share/zsh/site-functions")

if [ "$OS" = 'Linux' ]; then
  export ZSH_CACHE_DIR="${XDG_CACHE_HOME-"$HOME/.cache"}/zsh"
  fpath+=("$HOME/.local/share/zsh/site-functions")
fi
if [ "$OS" = 'Darwin' ]; then
  export ZSH_CACHE_DIR="$HOME/Library/Caches/zsh"
  fpath+=("$HOME/.zsh/completions")
fi

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

if [ $commands[starship] ]; then
  eval "$(starship init zsh)"
fi


COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

my_kubecontext() {
  local kubectl_version="$(kubectl version --client 2>/dev/null)"

  if [[ -n "$kubectl_version" ]]; then
    # Get the current Kuberenetes context
    local cur_ctx=$(kubectl config view -o=jsonpath='{.current-context}')
    cur_namespace="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${cur_ctx}\")].context.namespace}")"
    # If the namespace comes back empty set it default.
    if [[ -z "${cur_namespace}" ]]; then
      cur_namespace="default"
    fi

    if [[ "$cur_ctx" == "$cur_namespace" ]]; then
      # No reason to print out the same identificator twice
      echo -E $cur_ctx
    else
      echo -E $cur_ctx/$cur_namespace
    fi
  fi
}

POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_beginning"
POWERLEVEL9K_RVM_BACKGROUND="black"
POWERLEVEL9K_RVM_FOREGROUND="249"
POWERLEVEL9K_RVM_VISUAL_IDENTIFIER_COLOR="red"
POWERLEVEL9K_TIME_BACKGROUND="black"
POWERLEVEL9K_TIME_FOREGROUND="249"
POWERLEVEL9K_TIME_FORMAT="\UF43A %D{%I:%M}"
#POWERLEVEL9K_TIME_FORMAT="\UF43A %D{%I:%M  \UF133  %m.%d.%y}"
POWERLEVEL9K_RVM_BACKGROUND="black"
POWERLEVEL9K_RVM_FOREGROUND="249"
POWERLEVEL9K_RVM_VISUAL_IDENTIFIER_COLOR="red"
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='black'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='green'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='black'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='white'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='black'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='blue'
POWERLEVEL9K_FOLDER_ICON=''
POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE=true
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_VCS_UNTRACKED_ICON='\u25CF'
POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
POWERLEVEL9K_VCS_COMMIT_ICON="\uf417"
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{blue}\u256D\u2500%f"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{blue}\u2570\uf460%f "
POWERLEVEL9K_CUSTOM_MY_KUBECONTEXT=my_kubecontext
POWERLEVEL9K_CUSTOM_MY_KUBECONTEXT_BACKGROUND=025
POWERLEVEL9K_CUSTOM_MY_KUBECONTEXT_FOREGROUND=015
#POWERLEVEL9K_CUSTOM_MY_KUBECONTEXT_ICON=$'\u2388'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context os_icon ssh root_indicator dir dir_writable virtualenv vcs) # custom_my_kubecontext)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time status time)

HIST_STAMPS="mm/dd/yyyy"
DISABLE_UPDATE_PROMPT=true

# 
source ~/.zsh_plugins.sh

# bind UP and DOWN arrow keys
zmodload zsh/terminfo
if [[ "${terminfo[kcuu1]}" != "" ]]; then
  bindkey "$terminfo[kcuu1]" history-substring-search-up
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then
  bindkey "$terminfo[kcud1]" history-substring-search-down
fi

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

setopt nocorrectall

# Customize to your needs...
export LANG="en_US.utf-8"
export JAVA_OPTS="-Dfile.encoding=UTF-8"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export CLICOLOR=1
export VISUAL=vim
export EDITOR=$VISUAL

if [[ $OS = 'Darwin' ]]; then
  # Mac specific settings
  # since certain things (such as BSD ls)
  # differ from Linux
  alias vi="mvim -v"
  alias vim="mvim -v"
  alias gvim='mvim -g'
  export VISUAL='code -w'
  export EDITOR=$VISUAL
  #export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'
  export JDK_HOME="$(/usr/libexec/java_home -version 11)"
  export JAVA_HOME="$(/usr/libexec/java_home -version 11)"
else
  alias ngvim='nvim-wrapper'
  export VISUAL='code -w'
  export EDITOR=$VISUAL
fi

export PATH="$HOME/.rbenv/bin:$HOME/.go/bin:$PATH"
if [ $commands[go] ]; then
  export PATH="${${GOPATH-$HOME/go}//://bin:}/bin:$(go env GOROOT)/bin:$PATH"
fi
export PATH="$HOME/bin:$PATH"
export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'

#
# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

if [ $commands[hub] ]; then
  eval "$(hub alias -s)"
fi
if [ $commands[skaffold] ]; then
  source <(skaffold completion zsh)
fi
if [ $commands[kops] ]; then
  source <(kops completion zsh)
fi
if [ $commands[kind] ]; then
  source <(kind completion zsh)
fi

if [  $commands[nvim] ]; then
  export NVIM_LISTEN_ADDRESS=/tmp/neovim/neovim
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ $commands[bat] ]; then
  #export BAT_THEME="1337"
  #export BAT_THEME="DarkNeon"
  export BAT_THEME='Coldark-Dark'
  #alias cat="bat --plain"
  cat() { bat --plain --paging never "$@" }
fi

if [ $commands[prettyping] ]; then
  alias ping='prettyping --nolegend'
fi

if [ $commands[exa] ]; then
  alias l='exa -lh --git'
  alias la='exa -lah --git'
  alias ll='exa -lh --git'
  alias ls='exa -G'
  alias lsa='exa -lah --git'
  alias tree='exa --tree'
fi

if [ $commands[newt] ]; then
  eval "$(NEWT_OFFLINE=1 NEWT_QUIET=1 newt --completion-script-zsh)"
fi

if [ $commands[gotop] ]; then
  alias gotop='gotop -c monokai -p'
fi

# infocmp $TERM | sed 's/kbs=^[hH]/kbs=\177/' > $TERM.ti
# tic $TERM.ti
# alias tf=terraform

# complete -o nospace -C /usr/local/bin/mc mc

dcl(){ 
  git clone "${PWD##*/}/$*" 
}

export PATH="$HOME/.cargo/bin:$PATH"
export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_DEFAULT_OPTS="--ansi"

export nflx_registries=( us-east-1.streamingtest eu-west-1.streamingtest us-west-2.streamingtest )

[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
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
  lpath="$HOME/github/$(echo $1 | cut -d '/' -f 4)/$(echo "$1" | cut -d '/' -f 5 | cut -d '.' -f 1)"
  git clone "$1" "$lpath"
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

