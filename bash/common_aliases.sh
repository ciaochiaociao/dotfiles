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
alias ll="ls -la"
alias la="ls -a"
alias ls="ls --color=auto"
alias pd="pushd"
alias bd="popd"
alias sd="dirs -v"

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

# work dir
projdir () {
    cd $PROJDIR
}

workdir () {
    cd $(cat ~/.workdir)
}

alias cdw=workdir

change-workdir () {
    find $MYHOME -maxdepth 1 -type d | fzf > ~/.workdir
    cd $(cat ~/.workdir)
}

# \e[38;5;?m for foreground 256 colors 
# \e[48;5;?m for background
show_256_colors () {
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

show_16_colors () {
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

gp () {
	read -p "Are you sure to make a quick dirty commit and push to the repo? (y/n) " -n 1 ans
	ans=${ans:-n}
	if [[ ans == 'y' ]]; then
		git add .
		git commit -m 'temp'
	fi
	echo
	read -p "Push to the remote branch $(git rev-parse --abbrev-ref HEAD)? (y/n) " -n 1  ans
	echo
	ans=${ans:-n}
	if [[ ans == 'y' ]]; then
		git push
		echo "Pushed."
	fi
}

#echo "common_aliases.sh file loading successfully! "
alias gss='git status'
alias gswr='git switch --recurse-submodules'
alias gcor='git checkout --recurse-submodules'
alias gdrd='git diff --submodule=diff'
alias gdr='git diff --submodule'
alias gds='git diff --staged'
alias gmn='git merge --no-ff'
alias gcm='git commit -m'
alias gb='git branch'

add_to_common () {
	echo "$1" >> ~/dotfiles/bash/common_aliases.sh
	source ~/dotfiles/bash/common_aliases.sh
}

add_to_local () {
	echo "$1" >> ~/scripts/bashrc.sh
	source ~/dotfiles/bash/common_aliases.sh
}

open_common () {
	$EDITOR ~/dotfiles/bash/common_aliases.sh
}

open_local () {
	$EDITOR ~/scripts/bashrc.sh
}
alias open_vimrc="$EDITOR ~/dotfiles/vim/vimrc.vim"
alias l="ls"
