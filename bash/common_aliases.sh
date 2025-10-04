export EDITOR=vim
# These common aliases should be shell-agnostic.

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias .2="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."
alias l="ls -aCF"
alias ll="ls -laF"
alias la="ls -A"
alias ls="ls --color=auto -a"

cdn () {
    pushd . 
    for ((i=1; i<=$1; i++))
    do
        cd ..
    done
    pwd
}

cdu () {
    cd "${PWD%/$1/*}/$1"
}

# pushd, popd, dirs
alias po="popd"
pd () {
        pushd "$1" > /dev/null
}

alias dl="dirs -v"
dj () {
    local -a s; mapfile -t s < <(dirs -l -p)
    select d in "${s[@]}"; do
        [[ -n $d ]] || { echo "Invalid"; continue; }
        pushd "+$((REPLY-1))" > /dev/null || return 1
        break
    done
}

da () {
    local sel
    if [[ -z $1 ]]; then
        sel=$(fzf) || return 130
    else
        sel=$1
    fi
    [[ -d "$(realpath "$sel")" ]] && pushd -n -- "$(realpath "$sel")" || { echo "Invalid path: $sel"; return 1; }
}

dr () {
    popd -n "+$1"
}

# z
zz() {
  local dir
  dir="$(z -l "$@" \
        | awk '{ $1=""; sub(/^ /,""); print }' \
        | fzf)" || return
  [[ -n "$dir" ]] && builtin cd "$dir"
}

# z() {
#   if [[ -z "$1" ]]; then
#     cd "$(command z -l | awk '{print $2}' | fzf)"
#   else
#     command z -l "$@" | awk '{print $2}' | fzf | while read -r dir; do
#       cd "$dir" || return
#     done
#   fi
# }

# autojump
jj() {
  local dir
  dir="$(
    j -s 2>/dev/null |
      sed -n 's/^[[:space:]]*[0-9.]\+[:[:space:]]\+//p' |
      fzf
  )" || return
  [[ -n "$dir" ]] && builtin cd "$dir"
}

# work dir
projdir () {
    cd $PROJDIR
}

workdir () {
    cd $(cat ~/.workdir)
}

alias cdw=workdir

change-workdir () {
    find $MYHOME -maxdepth 1 -type d | fzf | xargs realpath > ~/.workdir
    cd $(cat ~/.workdir)
}

alias cwd=change-workdir

# \e[38;5;?m for foreground 256 colors 
# \e[48;5;?m for background
show-256-colors () {
	echo 'use \e[38;5;#m] syntax where # is the code below.'
	for i in {0..255}; do
	  printf "\e[38;5;${i}m%3s \e[0m" "$i"
	  if (( (i+1) % 16 == 0 )); then
	    echo
	  fi
	done
	echo
	echo 'use \e[48;5;#m] syntax where # is the code below.'
	for i in {0..255}; do
	  printf "\e[48;5;${i}m%3s \e[0m" "$i"
	  if (( (i+1) % 16 == 0 )); then
	    echo
	  fi
	done
}

show-16-colors () {
	echo 'use \e[#m] syntax where # is the code below.'
	for i in {30..37} {90..97}; do
		printf "\e[${i}m%3s\e[0m " "$i"
	done
	echo
	for i in {40..47} {100..107}; do
		printf "\e[${i}m%3s\e[0m " "$i"
	done
	echo
}

# git
gc! () {
    git commit --amend
}

gc!! () {
    git commit --amend --no-edit
}

gc!!! () {
    git commit --amend --no-edit
    git branch
    confirm-msg "Forced push to remote branch?" && git push --force
}
checkout () {
    git checkout --recurse-submodules $1 && \
    dvc checkout
}

switch () {
    git switch --recurse-submodules $1 && \
    dvc checkout
}

merge () {
    git merge $1 && \
    git submodule update
}

rebase () {
    git rebase $1 && \
    git submodule update
}

_read () {
    msg=$1
    if [[ "$(ps -p $$ -o comm=)" =~ */bash ]]; then
        read -p "$msg" -n 1 ans
    else
        echo $msg
        read ans
    fi
	ans=${ans:-n}
	echo
}

gpd () {
	# like git push "dirty"
    _read "Are you sure to make a quick dirty commit and push to the repo? (y/n) "
	if [[ $ans == 'y' ]]; then
        echo "Commiting changes ..."
		git add ~/dotfiles
		git commit -m 'temp'
	fi
    _read "Push to the remote branch $(git rev-parse --abbrev-ref HEAD)? (y/n) "
	if [[ $ans == 'y' ]]; then
		git push
		echo "Pushed."
	fi
}

#echo "common_aliases.sh file loading successfully! "
alias gss='git status'
alias gswr='git switch --recurse-submodules'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gd="git diff"
alias gdrd='git diff --submodule=diff'
alias gdr='git diff --submodule'
alias gds='git diff --staged'
alias gmn='git merge --no-ff'
alias gcm='git commit -m'
alias gb='git branch'
alias gp="git push"
alias gl="git log"
alias glga="git log --graph --all --decorate"
alias glg="git log --graph --decorate"
alias glg1="git log --graph --decorate --date=short --pretty=format:'%C(auto)%h %Cgreen%ad%Creset %C(bold red)%d%Creset %s'"
alias glga1="git log --graph --all --decorate --date=short --pretty=format:'%C(auto)%h %Cgreen%ad%Creset %C(bold red)%d%Creset %s'"
alias ga='git add'
alias gau='git add -u'
glcb () {
    glg1 --left-right HEAD...${1:-master}
}
# manage aliases
add-to-common () {
	echo "$1" >> ~/dotfiles/bash/common_aliases.sh
	source ~/dotfiles/bash/common_aliases.sh
    load-aliases
}

add-to-local () {
	echo "$1" >> ~/scripts/bashrc.sh
	source ~/dotfiles/bash/common_aliases.sh
    load-aliases
}

add-alias () {
    echo "alias $1=\"$2\"" >> ~/dotfiles/bash/common_aliases.sh
    load-aliases
}

open-common () {
	$EDITOR ~/dotfiles/bash/common_aliases.sh
    load-aliases
}

open-bashrc () {
	$EDITOR ~/dotfiles/bash/bashrc.sh
    load-shellrc
}

open-local () {
	$EDITOR ~/scripts/bashrc.sh
    load-aliases
}

open-install () {
    $EDITOR ~/dotfiles/bash/install_plugins.sh
    load-shellrc
}

load-aliases () {
    source ~/dotfiles/bash/common_aliases.sh
    source ~/scripts/bashrc.sh
    echo "Updated aliases."
}

load-shellrc () {
    case $SHELL in
        */bash) source ~/.bashrc;;
        */zsh) source ~/.zshrc;;
    esac
    echo "Updated shell rc file."
}

list-aliases () {
	declare -F | cut -d' ' -f 3 | grep -v '^_'
	alias
}

push-dotfiles () {
    (
        cd ~/dotfiles
        git add --all . && \
        git status && \
        _read "Commit message: "
        : ${ans:=temp}
        echo $ans
        git commit -m "$ans" && \
        git push
    )
}

pull-dotfiles () {
    (
        cd ~/dotfiles
        git pull
    )
}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# others
alias open-vimrc="$EDITOR ~/dotfiles/vim/vimrc.vim"
run-in-tmux () {
    local name="$1"
    shift
    tmux new-session -s $name $SHELL \; \
        send-keys "$* |& tee run-in-tmux.log; test ${PIPESTATUS[0]} -eq 0" C-m
}

run-in-tmux-detached () {
    local name="$1"
    shift
    tmux new-session -d -s $name $SHELL \; \
        send-keys "$* |& tee run-in-tmux.log; test ${PIPESTATUS[0]} -eq 0" C-m
}

run-parallel-in-tmux () {
    local name="${1?'Please provide the tmux session name'}"
    shift
	tmux attach-session -t "$name" \; \
		split-window -h $SHELL \; \
		send-keys "$*" C-m \; \
        set-option mouse on
}


alias vless='vim -R -'

show-path () {
    echo "${1:-$PATH}" | tr ":" "\n"
}

