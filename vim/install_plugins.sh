#!/bin/bash

# Directory where plugins will be installed (using native Vim 8 packages)
PACK_DIR="$HOME/.vim/pack/plugins/start"

# Create the directory
mkdir -p "$PACK_DIR"

# List of plugins to install based on vimrc.vim
# Format: "Author/PluginName"
PLUGINS=(
    "morhetz/gruvbox"
    "itchyny/lightline.vim"
    "mhinz/vim-startify"
    "junegunn/fzf"
    "junegunn/fzf.vim"
    "ojroques/vim-oscyank"
)

echo "Installing plugins to $PACK_DIR..."

for repo in "${PLUGINS[@]}"; do
    plugin_name=$(basename "$repo")
    plugin_path="$PACK_DIR/$plugin_name"
    
    if [ -d "$plugin_path" ]; then
        echo "Updating $plugin_name..."
        cd "$plugin_path" && git pull
    else
        echo "Installing $plugin_name..."
        git clone --depth 1 "https://github.com/$repo.git" "$plugin_path"
    fi
done

# Special handling for fzf (install binary)
if [ -f "$PACK_DIR/fzf/install" ]; then
    echo "Installing fzf binary..."
    "$PACK_DIR/fzf/install" --bin
fi

echo "Done! Plugins installed."
