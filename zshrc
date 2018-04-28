# Path to your oh-my-zsh configuration.
#tabs -2
# export ZSH=$HOME/.oh-my-zsh
export SHELL="${SHELL-/bin/zsh}"
export OS="${OS-$(uname)}"

zmodload zsh/terminfo

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

fpath+=("/usr/local/share/zsh/site-functions")
if [ "$OS" = 'Linux' ]; then
  fpath+=("/home/ivan/.local/share/zsh/site-functions")
fi

if [ ! -d "$HOME/.zgen" ]; then
  mkdir -p "$HOME/.zgen"
  git clone https://github.com/tarjoilija/zgen "$HOME/.zgen"
fi

source "$HOME/.zgen/zgen.zsh"

COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

SPACESHIP_TIME_SHOW=true
SPACESHIP_KUBECONTEXT_SYMBOL="☸️  "
[[ -n ${SSH_CLIENT} ]] && PROMPT_SYMBOL='' || PROMPT_SYMBOL=''
TIME_FORMAT="%D{%H:%M}"
GITHUB_ICON=''
EXECUTION_TIME_ICON="%F{yellow}%f" #    
EXECUTION_TIME_THRESHOLD=0.1
SPACESHIP_TIME_COLOR=yellow
SPACESHIP_CHAR_SYMBOL="${PROMPT_SYMBOL} "
SPACESHIP_CHAR_COLOR_SUCCESS=green
SPACESHIP_TIME_SUFFIX=" %F{192}%f "
SPACESHIP_DOCKER_PREFIX="%F{69}➜%f "
SPACESHIP_DOCKER_COLOR=75
SPACESHIP_RUST_COLOR=39
SPACESHIP_GIT_BRANCH_COLOR=141
SPACESHIP_GIT_STATUS_COLOR=165
SPACESHIP_KUBECONTEXT_PREFIX="%F{27}➜%f "
SPACESHIP_KUBECONTEXT_COLOR=33
SPACESHIP_TIME_COLOR=193
SPACESHIP_EXEC_TIME_SHOW=true
SPACESHIP_EXEC_TIME_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_EXEC_TIME_PREFIX="took $EXECUTION_TIME_ICON "
SPACESHIP_EXEC_TIME_COLOR="yellow"
SPACESHIP_EXEC_TIME_THRESHOLD=2000

if ! zgen saved; then
  echo "Creating zgen init"
  # ZSH plugin enhances the terminal environment with 256 colors.
  zgen load chrissicool/zsh-256color

  zgen oh-my-zsh

  # gcloud completion
  # zgen load https://github.com/littleq0903/gcloud-zsh-completion
  # zgen oh-my-zsh plugins/kubectl


  # Syntax highlighting bundle.
  zgen load zsh-users/zsh-syntax-highlighting

  # Guess what to install when running an unknown command
  # zgen oh-my-zsh plugins/command-not-found

  # alias tips
  # zgen load djui/alias-tips

  # nicoulaj's moar completion files for zsh
  zgen load zsh-users/zsh-completions src

  # git support
  zgen oh-my-zsh plugins/git
  zgen load voronkovich/gitignore.plugin.zsh

  # archlinux completion (does not exist in prezto)
  zgen oh-my-zsh plugins/archlinux

  # ubuntu completion (does not exist in prezto)
  # zgen oh-my-zsh plugins/ubuntu

  # systemd completion
  zgen oh-my-zsh plugins/systemd

  # gem completion
  zgen oh-my-zsh plugins/gem

  # ruby completion
  zgen oh-my-zsh plugins/ruby

  # bundler completin
  zgen oh-my-zsh plugins/bundler

  # Maven completion
  zgen oh-my-zsh plugins/mvn

  # pip completion
  zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/pip

  # node completion
  zgen oh-my-zsh plugins/node

  # npm completion
  zgen oh-my-zsh plugins/npm

  # rbenv completion
  zgen oh-my-zsh plugins/rbenv

  # rsync completion
  zgen oh-my-zsh plugins/rsync

  # docker completion
  zgen oh-my-zsh plugins/docker

  # vagrant completion
  zgen oh-my-zsh plugins/vagrant

  # packer.io completion
  zgen load gunzy83/packer-zsh-completion

  # vault completion
  zgen oh-my-zsh plugins/vault

  # terraform completion
  zgen oh-my-zsh plugins/terraform

  # httpie completion
  zgen oh-my-zsh plugins/httpie

  # Go command completion
  zgen oh-my-zsh plugins/golang

  # AWS command completion
  zgen oh-my-zsh plugins/aws

  # cp completion
  zgen oh-my-zsh plugins/cp

  # colorize
  # use pygments to highlight files by extenstion
  zgen oh-my-zsh plugins/colorize

  # extraction helpers
  zgen oh-my-zsh plugins/extract

  # fish like history search
  zgen load zsh-users/zsh-history-substring-search


  # bosh completion
  #zgen load frodenas/bosh-zsh-autocomplete-plugin

  zgen oh-my-zsh plugins/cargo
  zgen oh-my-zsh plugins/rust

  zgen load denysdovhan/spaceship-prompt spaceship
  #zgen load https://gist.github.com/7585b6aa8d4770866af4.git backchat
  zgen save
fi

# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

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

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
#alias ls='ls --color=auto'
alias la='ls -Ah'
alias ll='ls -alFh'
alias l='ls -CFh'

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
  export JDK_HOME="$(/usr/libexec/java_home -version 1.8)"
  export JAVA_HOME="$(/usr/libexec/java_home -version 1.8)"
else
  alias ngvim='nvim-wrapper'
  export VISUAL='code -w'
  export EDITOR=$VISUAL
fi

export PATH="$HOME/bin:${${GOPATH-$HOME/go}//://bin:}/bin:$GOROOT/bin:$HOME/.rbenv/bin:$PATH"
export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'
alias ccat=pygmentize

#export ANSIBLE_ROLES_PATH=/Users/ivan/projects/wordnik/ansible-playbooks/playbooks/roles:/etc/ansible/roles
export HADOOP_USER_NAME=hadoop

#
# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

if [ $commands[hub] ]; then
  eval "$(hub alias -s)"
fi

if [ $commands[rbenv] ]; then
  eval "$(rbenv init -)"
fi
if [ $commands[direnv] ]; then
  source <(direnv hook zsh)
fi
if [ $commands[minikube] ]; then
  source <(minikube completion zsh)
fi
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi
if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi

man() {
      env \
      	  LESS_TERMCAP_mb=$(printf "\e[1;34m") \
	  LESS_TERMCAP_md=$(printf "\e[1;34m") \
	  LESS_TERMCAP_me=$(printf "\e[0m") \
	  LESS_TERMCAP_se=$(printf "\e[0m") \
	  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	  LESS_TERMCAP_ue=$(printf "\e[0m") \
	  LESS_TERMCAP_us=$(printf "\e[1;33m") \
	  PAGER=/usr/bin/less \
	  _NROFF_U=1 \
	  PATH=${HOME}/bin:${PATH} \
	  			   man "$@"
}


[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

if [  $commands[nvim] ]; then
  export NVIM_LISTEN_ADDRESS=/tmp/neovim/neovim
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export ONECONCERN_PATH=$HOME/github/oneconcern
cdoc() { 
  cd "$ONECONCERN_PATH/$1"  || exit 1
}
