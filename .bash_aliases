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

if [ -f ~/.local_aliases ]; then
	source ~/.local_aliases
fi

if [ -f ~/.common_aliases ]; then
	source ~/.common_aliases
fi

echo ".bash_aliases file loading successfully! "
