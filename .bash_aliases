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

alias sshkey='
	if ! [ -f ~/.ssh/github_id_rsa ] && [ -f ~/.ssh/github_id_rsa.pub ]; then
		echo "--- This is a shell script that generates a private and public key if github_id_rsa and github_id_rsa.pub does not exists ---"
		echo "Start generating ssh private and public key, starting the ssh-agent, adding the private key to ssh-agent. "
		ssh-keygen -t rsa -b 4096 -N '' -f github_id_rsa -C "tony790927@gmail.com" && echo "tony790927@gmail" rsa has been generated || echo "\"rsa with tony790927@gmail\" can not be generate" 2>&1
		eval "$(ssh-agent -s)" && echo "start ssh agent" || echo "can not start ssh agent eval (ssh-agent -s)" 2>&1
		ssh-add ~/.ssh/github_id_rsa && echo "private key (github_id_rsa) has been added to ssh-agent" || echo "private key (github_id_rsa) can not be added to ssh-agent" 2>&1
		ssh -T git@github.com
		echo "Process finished successfully. The public key and the private key generated and added have been stored to ~/.ssh/github_id_rsa and ~/.ssh/github_id_rsa.pub. ATTENTION: For the last step, please go to GitHub to add the content of the github_id_rsa.pub to GitHub ssh keys page!"
	else
		echo "\"~/.ssh/github_id_rsa\" and \"~/.ssh/github_id_rsa.pub\" already exist" 2>&1
	
	fi
	'
