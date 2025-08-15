# https://www.gnu.org/software/bash/manual/html_node/Bash-History-Facilities.html
shopt -s histappend
HISTFILESIZE=10000
HISTSIZE=10000
HISTFILE=~/.bash_history_big

#export PS1=$'\[\e[33m\]\u \[\e[32m\] @\h \[\e[1;36m\] :\W $ \[\e[0;0m\]'
#export PS1=$'\[\e[33m\]\u \[\e[36m\] @\h \[\e[35m\]:\W $ \[\e[0m\]'
#export PS1=$'\[\e[32m\] @\h\[\e[1;36m\] :\W $ \[\e[0;0m\]'
export PS1=$'\[\e[36m\] @\h \[\e[35m\]:\W $ \[\e[0m\]'
