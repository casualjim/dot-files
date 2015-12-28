# Path to your oh-my-zsh configuration.
#tabs -2
# export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export OS=`uname`

zmodload zsh/terminfo
fpath+=("/usr/local/share/zsh/site-functions")

. /usr/share/zsh/scripts/zgen/zgen.zsh

COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

if ! zgen saved; then
  echo "Creating zgen init"

  zgen oh-my-zsh

  # ZSH plugin enhances the terminal environment with 256 colors.
  zgen load chrissicool/zsh-256color

  # Syntax highlighting bundle.
  zgen load zsh-users/zsh-syntax-highlighting

  # Guess what to install when running an unknown command
  zgen oh-my-zsh plugins/command-not-found

  # alias tips
  zgen load djui/alias-tips

  # nicoulaj's moar completion files for zsh
  zgen load zsh-users/zsh-completions src

  # git support
  zgen oh-my-zsh plugins/git
  zgen load voronkovich/gitignore.plugin.zsh
  zgen load supercrabtree/k

  # jump to last working directory
  zgen oh-my-zsh plugins/last-working-dir

  # archlinux completion (does not exist in prezto)
  zgen oh-my-zsh plugins/archlinux

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
export EC2_HOME="/usr/local/opt/ec2-api-tools/libexec"
export EC2_AMITOOL_HOME="/usr/local/opt/ec2-ami-tools/libexec"
export AWS_IAM_HOME="/usr/local/opt/aws-iam-tools/libexec"
export AWS_ELB_HOME="/usr/local/opt/elb-tools/jars"

export LANG="en_US.utf-8"
export JAVA_OPTS="-Dfile.encoding=UTF-8"
export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules
export GOPATH=$HOME/go
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export HIVE_HOME=/usr/local/opt/hive/libexec
export HCAT_HOME=/usr/local/opt/hive/libexec/hcatalog
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

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
  eval "$(docker-machine env localdocker)"
fi

if [ -d $HOME/.linuxbrew ]; then
  export PATH="$HOME/.linuxbrew/bin:$PATH"
  export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

export PATH="$GOPATH/bin:$GOROOT/bin:$HOME/.rbenv/bin:$PATH"


export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'
alias ccat="pygmentize -g -O 'tabsize=2'"

export ANSIBLE_ROLES_PATH=/Users/ivan/projects/wordnik/ansible-playbooks/playbooks/roles:/etc/ansible/roles
alias zinc='zinc -nailed'
export HADOOP_USER_NAME=hadoop

#
# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

eval "$(hub alias -s)"
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

# added by travis gem
[ -f /home/ivan/.travis/travis.sh ] && source /home/ivan/.travis/travis.sh
