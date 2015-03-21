# Path to your oh-my-zsh configuration.
tabs -2
fpath=(/usr/local/share/zsh-completions /usr/local/share/zsh/site-functions $fpath)
# export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export OS=`uname`

source $HOME/.antigen/antigen.zsh

COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

plugins=(
         history
         git
         git-flow
         gem
         redis-cli
         osx
         ruby
         bundler
         brew
         mvn
         heroku
         pip
         node
         npm
         rbenv
         rsync
         sbt
         scala
         docker
         vagrant
         tmux
         tmuxinator
         golang
         aws
         cp
         atom)

# Bundles from the default repo (robbyrussell's oh-my-zsh).
for p in $plugins; do
  antigen bundle "$p"
done

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Fish shell's history search functionality bundle.
antigen bundle zsh-users/zsh-history-substring-search

# ZSH plugin enhances the terminal environment with 256 colors.
antigen bundle chrissicool/zsh-256color

# Autoupdate Antigen every 7 days.
antigen bundle unixorn/autoupdate-antigen.zshplugin

antigen theme https://gist.github.com/7585b6aa8d4770866af4.git backchat-remote

antigen apply

# Customize to your needs...
export EC2_HOME="/usr/local/opt/ec2-api-tools/libexec"
export EC2_AMITOOL_HOME="/usr/local/opt/ec2-ami-tools/libexec"
export AWS_IAM_HOME="/usr/local/opt/aws-iam-tools/libexec"
export AWS_ELB_HOME="/usr/local/opt/elb-tools/jars"

export LANG="en_US.utf-8"
export LC_ALL="en_US.utf-8"
export JAVA_OPTS="-Dfile.encoding=UTF-8"
export JDK_HOME="$(/usr/libexec/java_home -version 1.8)"
export JAVA_HOME="$(/usr/libexec/java_home -version 1.8)"
export VIM_PREFIX='TERM=xterm-256color'
export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/go
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export HIVE_HOME=/usr/local/opt/hive/libexec
export HCAT_HOME=/usr/local/opt/hive/libexec/hcatalog

alias ls='ls -aF'
sbt_sub() { mkdir -p src/{main,test}/scala/$1 src/{main,test}/resources }

alias clean_sbt='rm -rf "$HOME/.sbt/staging" "$HOME/.sbt/plugins/project/target" "*/target"'

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
  export CLICOLOR=1
else
  alias vi='$VIM_PREFIX vim'
  alias vim='$VIM_PREFIX vim'
fi

export PATH="$GOROOT/bin:$HOME/.rbenv/bin:$PATH"

export MAVEN_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=384m -Xss4m -XX:ReservedCodeCacheSize=128m"

alias snoop='sudo ngrep -d en0 -q -W byline port 8080'
alias snoopLocal='sudo ngrep -d lo0 -q -W byline port 8060'
alias update-sbt-script='curl -OLs https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt && chmod +x sbt'

alias sbt-jrebel='SBT_OPTS="-javaagent:$HOME/Applications/JRebel/jrebel.jar -Drebel.mustache_plugin=true $SBT_OPTS" sbt'
alias sbt-debug='SBT_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 $SBT_OPTS" sbt'
alias sbt-yourkit='SBT_OPTS="-agentpath:/Applications/YourKit.app/bin/mac/libyjpagent.jnilib $SBT_OPTS" sbt'
alias ccat="pygmentize -g -O 'tabsize=2'"
alias knife="nocorrect knife"

#export PATH="${GOPATH//://bin:}/bin:$PATH"
export ANSIBLE_ROLES_PATH=/Users/ivan/projects/wordnik/ansible-playbooks/playbooks/roles:/etc/ansible/roles
alias zinc='zinc -nailed'
export HADOOP_USER_NAME=hadoop
#
# added by travis gem
[ -f /Users/ivan/.travis/travis.sh ] && source /Users/ivan/.travis/travis.sh

eval "$(gh alias -s)"
eval "$(direnv hook zsh)"
eval "$(docker-machine env localdocker)"

[ -f $HOME/.zshrc.local ] && . $HOME/.zshrc.local
