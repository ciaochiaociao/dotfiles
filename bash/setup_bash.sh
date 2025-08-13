mkdir -p ~/scripts/bashrc.sh
touch ~/scripts/bashrc.sh

echo """
# local
if [ -f ~/scripts/bashrc.sh ]; then
	. ~/scripts/bashrc.sh
fi

# remote
if [ -f ~/dotfiles/bash/bashrc.sh ]; then
	. ~/dotfiles/bash/bashrc.sh
fi

# shell-agnostic aliases
if [ -f ~/dotfiles/bash/common_aliases.sh ]; then
	. ~/dotfiles/bash/common_aliases.sh
fi""" >> ~/.bashrc
