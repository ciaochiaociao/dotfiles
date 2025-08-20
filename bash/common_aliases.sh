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
alias dl="dirs -v"

dc () {
    [[ -d $1 ]] || { echo "No such dir: $1" >&2; return 1; }
    pushd "$1" > /dev/null
}

dj () {
    local -a s; mapfile -t s < <(dirs -l -p)
    select d in "${s[@]}"; do
        [[ -n $d ]] || { echo "Invalid"; continue; }
        pushd "+$((REPLY-1))" > /dev/null || return 1
        break
    done
}

da () {
    [[ -d "$(realpath "$1")" ]] && pushd -n "$(realpath "$1")" || { echo "Invalid path: $1"; return 1; }
}

dr () {
    popd -n "+$1"
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
	git commit --fixup HEAD~1
	git rebase -i --autosquash HEAD~2
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

gpd () {
	# like git push "dirty"
	read -p "Are you sure to make a quick dirty commit and push to the repo? (y/n) " -n 1 ans
	ans=${ans:-n}
	echo
	if [[ $ans == 'y' ]]; then
        echo "Commiting changes ..."
		git add ~/dotfiles
		git commit -m 'temp'
	fi
	read -p "Push to the remote branch $(git rev-parse --abbrev-ref HEAD)? (y/n) " -n 1  ans
	ans=${ans:-n}
	echo
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

# manage aliases
add-to-common () {
	echo "$1" >> ~/dotfiles/bash/common_aliases.sh
	source ~/dotfiles/bash/common_aliases.sh
    load-bashrc
}

add-to-local () {
	echo "$1" >> ~/scripts/bashrc.sh
	source ~/dotfiles/bash/common_aliases.sh
    load-bashrc
}

open-common () {
	$EDITOR ~/dotfiles/bash/common_aliases.sh
    load-bashrc
}

open-bashrc () {
	$EDITOR ~/dotfiles/bash/bashrc.sh
    load-bashrc
}

open-local () {
	$EDITOR ~/scripts/bashrc.sh
    load-bashrc
}

load-bashrc () {
    source ~/.bashrc
    echo "Loaded shell rc file."
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
        read -p "Commit message: " msg
        : ${msg:=temp}
        echo $msg
        git commit -m "$msg" && \
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
    tmux new -s temp $SHELL \; \
        send-keys "$1" C-m
}
