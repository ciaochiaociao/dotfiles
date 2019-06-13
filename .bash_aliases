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

alias ndr='nvidia-docker run --shm-size=2g --ulimit memlock=-1 --rm --ulimit stack=67108864 -it -e NVIDIA_VISIBLE_DEVICES=1 -v /home/cwhsu/tmp/_mylocal:/home/cwhsu/_mylocal nvcr.io/nvidia/tensorflow:18.06-py3'

alias vialias="vi ~/.bash_aliases"

if [ -f ~/.bash_local ]; then
	source ~/.bash_local
	alias vilocal="vi ~/.bash_local"
fi
