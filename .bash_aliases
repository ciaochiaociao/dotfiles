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
alias 51="ssh 140.109.19.51"
alias 191="ssh 140.109.19.191"
alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../../.."
alias ....="cd ../../../.."
alias .....="cd ../../../../.."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias .2="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."
alias c="clear"
alias ll="ls -la"
alias ls="ls --color=auto"
alias l.="ls -d . --color=auto"


alias vialias="vi ~/.bash_aliases"
alias loadbash="source ~/.bashrc"
alias vib="vi ~/.bashrc"

if [ -f ~/.bash_local ]; then
	source ~/.bash_local
	alias vilocal="vi ~/.bash_local"
fi
echo ".bash file loading successfully! "
