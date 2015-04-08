# Path to your oh-my-zsh configuration.
#tabs -2
# export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export OS=`uname`

zmodload zsh/terminfo
fpath+=("/usr/local/share/zsh/site-functions")

source $HOME/.antigen/antigen.zsh

COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

# Load the oh-my-zsh's library.
antigen use oh-my-zsh


antigen bundles <<BUNDLES

# ZSH plugin enhances the terminal environment with 256 colors.
chrissicool/zsh-256color

# Syntax highlighting bundle.
zsh-users/zsh-syntax-highlighting

# Guess what to install when running an unknown command
command-not-found

# better history
history

# nicoulaj's moar completion files for zsh
zsh-users/zsh-completions src

# git support
git
git-extras
git-flow
voronkovich/gitignore.plugin.zsh

# gem completion
gem

# redis client completion
redis-cli

# osx helpers
osx

# ruby completion
ruby

# bundler completin
bundler

# homebrew completion
brew

# Maven completion
mvn

# heroku completion
heroku

# pip completion
pip

# node completion
node

# npm completion
npm

# rbenv completion
rbenv

# rsync completion
rsync

# sbt completion
sbt

# scala completion
scala

# docker completion
docker

# vagrant completion
vagrant

# Go command completion
golang

# AWS command completion
aws

# cp completion
cp

# extraction helpers
extract


# fish like history search
zsh-users/zsh-history-substring-search

# pretty prompt
#nojhan/liquidprompt

# Autoupdate Antigen every 7 days.
unixorn/autoupdate-antigen.zshplugin
BUNDLES

antigen theme https://gist.github.com/7585b6aa8d4770866af4.git backchat

antigen apply

export LP_MARK_PREFIX='
'

setopt nocorrectall
# Customize to your needs...
export EC2_HOME="/usr/local/opt/ec2-api-tools/libexec"
export EC2_AMITOOL_HOME="/usr/local/opt/ec2-ami-tools/libexec"
export AWS_IAM_HOME="/usr/local/opt/aws-iam-tools/libexec"
export AWS_ELB_HOME="/usr/local/opt/elb-tools/jars"

export LANG="en_US.utf-8"
export LC_ALL="en_US.utf-8"
export JAVA_OPTS="-Dfile.encoding=UTF-8"
#export JDK_HOME="$(/usr/libexec/java_home -version 1.8)"
#export JAVA_HOME="$(/usr/libexec/java_home -version 1.8)"
#export VIM_PREFIX='TERM=xterm-256color'
export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules
export GOROOT=$HOME/tools/go/gonative/go
export GOPATH=$HOME/go
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export HIVE_HOME=/usr/local/opt/hive/libexec
export HCAT_HOME=/usr/local/opt/hive/libexec/hcatalog
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls --color=auto'
alias la='ls -A'
alias ll='ls -alF'
alias l='ls -CF'
sbt_sub() { mkdir -p src/{main,test}/scala/$1 src/{main,test}/resources }

alias clean_sbt='rm -rf "$HOME/.sbt/staging" "$HOME/.sbt/plugins/project/target" "*/target"'

export CLICOLOR=1
if [[ $OS = 'Darwin' ]]; then
  # Mac specific settings
  # since certain things (such as BSD ls)
  # differ from Linux
  alias vi="$VIM_PREFIX mvim -v"
  alias vim="$VIM_PREFIX mvim -v"
  alias gvim='mvim -g'
  export VISUAL='atom -w'
  export EDITOR=$VISUAL
  #export EDITOR='mvim -f -c "au VimLeave * !open -a iTerm"'
  eval "$(docker-machine env localdocker)"
else
  alias vi='$VIM_PREFIX vim'
  alias vim='$VIM_PREFIX vim'
fi

export PATH="$GOPATH/bin:$GOROOT/bin:$HOME/.rbenv/bin:$PATH"

export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'
alias update-sbt-script='curl -OLs https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt && chmod +x sbt'

alias sbt-jrebel='SBT_OPTS="-javaagent:$HOME/Applications/JRebel/jrebel.jar -Drebel.mustache_plugin=true $SBT_OPTS" sbt'
alias sbt-debug='SBT_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 $SBT_OPTS" sbt'
alias sbt-yourkit='SBT_OPTS="-agentpath:/Applications/YourKit.app/bin/mac/libyjpagent.jnilib $SBT_OPTS" sbt'
alias ccat="pygmentize -g -O 'tabsize=2'"
alias knife="nocorrect knife"
alias prodenv=". $HOME/.config/boatwright/production-env"
alias devenv=". $HOME/.config/boatwright/dev-env"

. $HOME/.config/boatwright/production-env

#export PATH="${GOPATH//://bin:}/bin:$PATH"
export ANSIBLE_ROLES_PATH=/Users/ivan/projects/wordnik/ansible-playbooks/playbooks/roles:/etc/ansible/roles
alias zinc='zinc -nailed'
export HADOOP_USER_NAME=hadoop

#
# added by travis gem
[ -f /Users/ivan/.travis/travis.sh ] && source /Users/ivan/.travis/travis.sh

eval "$(hub alias -s)"
eval "$(direnv hook zsh)"
eval "$(shipwright init)"

[ -f $HOME/.zshrc.local ] && . $HOME/.zshrc.local
