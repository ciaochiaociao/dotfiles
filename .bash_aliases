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

export MYHOME=/mnt/storage/users/chiahsu

# work dir
myhome () {
    cd $MYHOME
}

trip_utils () {
    cd $MYHOME/trip_utils
}

workdir () {
    cd $(cat ~/.workdir)
}

alias cdw=workdir

change-workdir () {
    find $MYHOME -maxdepth 1 -type d | fzf > ~/.workdir
    cd $(cat ~/.workdir)
}

# git
gc! () {
	git commit --fixup HEAD~1
	git rebase -i --autosquash HEAD~2
}

if [ -f ~/.local_aliases ]; then
	source ~/.local_aliases
fi

if [ -f ~/.common_aliases ]; then
	source ~/.common_aliases
fi

#echo ".bash_aliases file loading successfully! "
