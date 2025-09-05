mkdir -p ~/scripts
touch ~/scripts/bashrc.sh

echo """
# shell-agnostic aliases
[ -f ~/dotfiles/bash/common_aliases.sh ] && . ~/dotfiles/bash/common_aliases.sh

# local
[ -f ~/scripts/bashrc.sh ] && source ~/scripts/bashrc.sh

# remote
[ -f ~/dotfiles/bash/bashrc.sh ] && . ~/dotfiles/bash/bashrc.sh

""" >> ~/.bashrc

# add keyphrases to ssh-agent
echo """
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" >/dev/null
fi
""" >> ~/.bashrc

echo """
source ~/dotfiles/vim/vimrc.vim
""" >> ~/.vimrc

read -p "What is your project directory? " PROJDIR
if [[ PROJDIR != "" ]]; then
    echo "export PROJDIR=$PROJDIR" >> ~/scripts/bashrc.sh
else
    echo "Project diretorcy is not set. Please manually export PROJDIR in ~/.bashrc"
fi
