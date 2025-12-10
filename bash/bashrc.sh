#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/Bash-History-Facilities.html
shopt -s histappend
HISTFILESIZE=10000
HISTSIZE=10000
HISTFILE=~/.bash_history_big

#export PS1=$'\[\e[33m\]\u \[\e[32m\] @\h \[\e[1;36m\] :\W $ \[\e[0;0m\]'
#export PS1=$'\[\e[33m\]\u \[\e[36m\] @\h \[\e[35m\]:\W $ \[\e[0m\]'
#export PS1=$'\[\e[32m\] @\h\[\e[1;36m\] :\W $ \[\e[0;0m\]'

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [[ "$SHELL" =~ .*/bash ]]; then
    if [ "$color_prompt" = yes ]; then
        PS1='\[\033[01;37m\]${debian_chroot:+($debian_chroot)} \[\033[01;36m\] @\h: \[\033[01;35m\]\W $ \[\033[00m\]'
    else
        PS1='${debian_chroot:+($debian_chroot)} @\h: \W\$ '
    fi
    unset color_prompt force_color_prompt
    case "$TERM" in
        xterm*|rxvt*)
            PS1=$'\[\e[37m\]${debian_chroot:+($debian_chroot)} \[\e[36m\] @\h: \[\e[35m\]\W $ \[\e[0m\]'
            ;;
        *)
            ;;
    esac
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export TZ="America/Chicago"
export HISTTIMEFORMAT="%F %TI "
