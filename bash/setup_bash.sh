mkdir -p ~/scripts
touch ~/scripts/bashrc.sh

echo """
# local
[ -f ~/scripts/bashrc.sh ] && source ~/scripts/bashrc.sh

# remote
[ -f ~/dotfiles/bash/bashrc.sh ] && . ~/dotfiles/bash/bashrc.sh

# shell-agnostic aliases
[ -f ~/dotfiles/bash/common_aliases.sh ] && . ~/dotfiles/bash/common_aliases.sh
""" >> ~/.bashrc

echo """
source ~/dotfiles/vim/vimrc.vim
""" >> ~/.vimrc
