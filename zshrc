# Path to your oh-my-zsh configuration.
#tabs -2
# export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export OS=`uname`

zmodload zsh/terminfo
fpath+=("/usr/local/share/zsh/site-functions")

. /usr/share/zgen/zgen.zsh

COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

. ~/google-cloud-sdk/path.zsh.inc
. <(grep -v compinit ~/google-cloud-sdk/completion.zsh.inc)
. <(kubectl completion zsh  | grep -v '^autoload .*compinit$')


if ! zgen saved; then
  echo "Creating zgen init"

  zgen oh-my-zsh
  
  # gcloud completion
  zgen load https://github.com/littleq0903/gcloud-zsh-completion
  zgen oh-my-zsh plugins/kubectl

  # ZSH plugin enhances the terminal environment with 256 colors.
  zgen load chrissicool/zsh-256color

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
  zgen load supercrabtree/k

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
  zgen load frodenas/bosh-zsh-autocomplete-plugin

  zgen load https://gist.github.com/7585b6aa8d4770866af4.git backchat
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
export GOPATH=$HOME/go

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
#alias ls='ls --color=auto'
alias la='ls -A'
alias ll='ls -alF'
alias l='ls -CF'

export DOCKER_HOST=unix:///var/run/docker.sock
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
  export VISUAL='atom -w'
  export EDITOR=$VISUAL
  #export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'
  export JDK_HOME="$(/usr/libexec/java_home -version 1.8)"
  export JAVA_HOME="$(/usr/libexec/java_home -version 1.8)"
fi

export PATH="$HOME/bin:${GOPATH//://bin:}/bin:$GOROOT/bin:$HOME/.rbenv/bin:$PATH"
export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'
alias ccat=colorize

#export ANSIBLE_ROLES_PATH=/Users/ivan/projects/wordnik/ansible-playbooks/playbooks/roles:/etc/ansible/roles
export HADOOP_USER_NAME=hadoop

#
# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

#eval "$(hub alias -s)"
function git(){hub $@}
eval "$(direnv hook zsh)"
# eval "$(shipwright init)"

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


[ -f $HOME/.zshrc.local ] && . $HOME/.zshrc.local

NVIM_LISTEN_ADDRESS=/tmp/neovim/neovim

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(zb complete)"
