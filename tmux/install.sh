#!/bin/bash
# Bootstrap tmux config: oh-my-tmux + dotfiles tmux.conf.local

set -e

TMUX_DIR="$HOME/.config/tmux"
OMT_DIR="$TMUX_DIR/oh-my-tmux"
DOTFILES_LOCAL="$HOME/dotfiles/tmux/tmux.conf.local"

mkdir -p "$TMUX_DIR"

# Clone oh-my-tmux if missing
if [ ! -d "$OMT_DIR" ]; then
    echo "Cloning oh-my-tmux into $OMT_DIR..."
    git clone https://github.com/gpakosz/.tmux.git "$OMT_DIR"
else
    echo "oh-my-tmux already present at $OMT_DIR"
fi

# Symlink main tmux.conf -> oh-my-tmux's .tmux.conf
ln -sfn "$OMT_DIR/.tmux.conf" "$TMUX_DIR/tmux.conf"
echo "Linked $TMUX_DIR/tmux.conf -> $OMT_DIR/.tmux.conf"

# Symlink tmux.conf.local -> dotfiles version
if [ ! -f "$DOTFILES_LOCAL" ]; then
    echo "Error: $DOTFILES_LOCAL not found" >&2
    exit 1
fi
ln -sfn "$DOTFILES_LOCAL" "$TMUX_DIR/tmux.conf.local"
echo "Linked $TMUX_DIR/tmux.conf.local -> $DOTFILES_LOCAL"

echo "Done. Reload with: tmux source-file $TMUX_DIR/tmux.conf"
