mkdir -p ~/scripts
touch ~/scripts/zshrc.sh

echo """
# local
[ -f ~/scripts/zshrc.sh ] && source ~/scripts/zshrc.sh

# shell-agnostic aliases
[ -f ~/dotfiles/bash/common_aliases.sh ] && . ~/dotfiles/bash/common_aliases.sh
""" >> ~/.zshrc

echo """
source ~/dotfiles/vim/vimrc.vim
""" >> ~/.vimrc

read -p "What is your project directory? " PROJDIR
if [[ PROJDIR != "" ]]; then
    echo "export PROJDIR=$PROJDIR" >> ~/scripts/zshrc.sh
else
    echo "Project diretorcy is not set. Please manually export PROJDIR in ~/.zshrc"
fi
