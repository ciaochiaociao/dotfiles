#!/bin/bash
set -e

# ── Detect environment ────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"
CURRENT_SHELL="$(basename "$SHELL")"
SHELLRC="$HOME/.${CURRENT_SHELL}rc"
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " Dotfiles Setup"
echo "========================================"
echo " OS:       $OS ($ARCH)"
echo " Shell:    $CURRENT_SHELL ($SHELLRC)"
echo " Dotfiles: $DOTFILES"
echo "========================================"
echo

# ── Helper ─────────────────────────────────────────────────────────────────
step() {
    echo
    echo "── $1 ──"
}

ask() {
    read -p "$1 (y/n) " -n 1 ans
    echo
    [[ "$ans" == "y" ]]
}

already_has() {
    local pattern="$1"
    local file="$2"
    [[ -f "$file" ]] && grep -qF "$pattern" "$file"
}

# ── 1. Shell config ───────────────────────────────────────────────────────
step "Shell config"

mkdir -p ~/scripts

case "$CURRENT_SHELL" in
    bash)
        touch ~/scripts/bashrc.sh

        if ! already_has "dotfiles/bash/common_aliases.sh" "$SHELLRC"; then
            echo "Appending dotfiles sources to $SHELLRC..."
            cat >> "$SHELLRC" <<EOF

# ── dotfiles ──
# shell-agnostic aliases
[ -f ~/dotfiles/bash/common_aliases.sh ] && . ~/dotfiles/bash/common_aliases.sh

# local overrides
[ -f ~/scripts/bashrc.sh ] && source ~/scripts/bashrc.sh

# bash-specific config
[ -f ~/dotfiles/bash/bashrc.sh ] && . ~/dotfiles/bash/bashrc.sh
EOF
        else
            echo "Shell config already sourced in $SHELLRC. Skipping."
        fi

        # ssh-agent auto-start
        if ! already_has "SSH_AUTH_SOCK" "$SHELLRC"; then
            cat >> "$SHELLRC" <<'EOF'

# ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" >/dev/null
fi
EOF
        fi
        ;;
    zsh)
        touch ~/scripts/zshrc.sh

        if ! already_has "dotfiles/bash/common_aliases.sh" "$SHELLRC"; then
            echo "Appending dotfiles sources to $SHELLRC..."
            cat >> "$SHELLRC" <<EOF

# ── dotfiles ──
# shell-agnostic aliases
[ -f ~/dotfiles/bash/common_aliases.sh ] && . ~/dotfiles/bash/common_aliases.sh

# local overrides
[ -f ~/scripts/zshrc.sh ] && source ~/scripts/zshrc.sh
EOF
        else
            echo "Shell config already sourced in $SHELLRC. Skipping."
        fi
        ;;
    *)
        echo "Unsupported shell: $CURRENT_SHELL (only bash and zsh are supported)"
        echo "Skipping shell config. You can manually source ~/dotfiles/bash/common_aliases.sh"
        ;;
esac

# ── 2. Vim ─────────────────────────────────────────────────────────────────
step "Vim"

if command -v vim &>/dev/null; then
    if ! already_has "dotfiles/vim/vimrc.vim" ~/.vimrc; then
        echo "Sourcing vimrc.vim from ~/.vimrc..."
        cat >> ~/.vimrc <<'EOF'

source ~/dotfiles/vim/vimrc.vim
EOF
    else
        echo "vimrc.vim already sourced. Skipping."
    fi

    echo "Installing vim plugins..."
    bash "$DOTFILES/vim/install_plugins.sh"
else
    echo "vim not found. Skipping."
fi

# ── 3. Neovim ──────────────────────────────────────────────────────────────
step "Neovim"

NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if command -v nvim &>/dev/null; then
    mkdir -p "$NVIM_CONFIG_DIR"
    if [[ -L "$NVIM_CONFIG_DIR/init.lua" ]]; then
        echo "init.lua symlink already exists. Skipping."
    elif [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
        echo "WARNING: $NVIM_CONFIG_DIR/init.lua exists but is not a symlink."
        echo "Back it up and re-run, or manually symlink:"
        echo "  ln -sf $DOTFILES/vim/init.lua $NVIM_CONFIG_DIR/init.lua"
    else
        ln -sf "$DOTFILES/vim/init.lua" "$NVIM_CONFIG_DIR/init.lua"
        echo "Symlinked $NVIM_CONFIG_DIR/init.lua -> $DOTFILES/vim/init.lua"
    fi

    # Install lazy.nvim plugin manager if missing
    LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
    if [[ ! -d "$LAZY_DIR" ]]; then
        echo "Installing lazy.nvim..."
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
    else
        echo "lazy.nvim already installed."
    fi

    echo "Run 'nvim' to trigger lazy.nvim plugin installation."
else
    echo "nvim not found. Skipping."
    if ask "Would you like to install neovim?"; then
        if [[ "$OS" == "Darwin" ]]; then
            brew install neovim
        elif command -v apt &>/dev/null; then
            sudo apt install -y neovim
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y neovim
        else
            echo "Please install neovim manually: https://neovim.io"
        fi
        # Re-run nvim setup if install succeeded
        if command -v nvim &>/dev/null; then
            mkdir -p "$NVIM_CONFIG_DIR"
            ln -sf "$DOTFILES/vim/init.lua" "$NVIM_CONFIG_DIR/init.lua"
            LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
            [[ ! -d "$LAZY_DIR" ]] && git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
            echo "Neovim configured. Run 'nvim' to install plugins."
        fi
    fi
fi

# ── 4. Tmux ────────────────────────────────────────────────────────────────
step "Tmux"

if command -v tmux &>/dev/null; then
    bash "$DOTFILES/tmux/install.sh"
else
    echo "tmux not found. Skipping."
    if ask "Would you like to install tmux?"; then
        if [[ "$OS" == "Darwin" ]]; then
            brew install tmux
        elif command -v apt &>/dev/null; then
            sudo apt install -y tmux
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y tmux
        else
            echo "Please install tmux manually."
        fi
        if command -v tmux &>/dev/null; then
            bash "$DOTFILES/tmux/install.sh"
        fi
    fi
fi

# ── 5. ctags ───────────────────────────────────────────────────────────────
step "ctags config"

if [[ ! -f ~/.ctags ]] && [[ ! -f ~/.ctags.d/default.ctags ]]; then
    if command -v ctags &>/dev/null; then
        # Universal ctags uses ~/.ctags.d/, exuberant ctags uses ~/.ctags
        if ctags --version 2>/dev/null | grep -q "Universal"; then
            mkdir -p ~/.ctags.d
            ln -sf "$DOTFILES/others/.ctags" ~/.ctags.d/default.ctags
            echo "Symlinked ~/.ctags.d/default.ctags"
        else
            ln -sf "$DOTFILES/others/.ctags" ~/.ctags
            echo "Symlinked ~/.ctags"
        fi
    else
        echo "ctags not found. Skipping."
    fi
else
    echo "ctags config already exists. Skipping."
fi

# ── 6. Fonts ──────────────────────────────────────────────────────────────
step "Nerd Fonts"

if [[ "$OS" == "Darwin" ]]; then
    if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null 2>&1; then
        echo "JetBrains Mono Nerd Font already installed. Skipping."
    elif ask "Install JetBrains Mono Nerd Font?"; then
        brew install --cask font-jetbrains-mono-nerd-font
    fi
elif [[ "$OS" == "Linux" ]]; then
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        echo "JetBrains Mono Nerd Font already installed. Skipping."
    elif ask "Install JetBrains Mono Nerd Font?"; then
        bash "$DOTFILES/bash/install_fonts.sh"
    fi
fi

# ── 7. CLI tools ──────────────────────────────────────────────────────────
step "CLI tools"

echo "Choose how to install CLI tools:"
echo "  1) Interactive batch installer (install_plugins_refactored.sh)"
echo "  2) Claude-powered installer (requires claude CLI)"
echo "  3) Skip"
read -p "Choice [1/2/3]: " -n 1 tools_choice
echo

case "$tools_choice" in
    1) bash "$DOTFILES/bash/install_plugins_refactored.sh" ;;
    2) bash "$DOTFILES/bash/install_plugins_claude.sh" ;;
    3) echo "Skipping CLI tools." ;;
    *) echo "Invalid choice. Skipping." ;;
esac

# ── 8. Project directory ──────────────────────────────────────────────────
step "Project directory"

LOCAL_RC="$HOME/scripts/${CURRENT_SHELL}rc.sh"
if ! already_has "PROJDIR" "$LOCAL_RC"; then
    read -p "Set your project directory (or Enter to skip): " PROJDIR
    if [[ -n "$PROJDIR" ]]; then
        echo "export PROJDIR=\"$PROJDIR\"" >> "$LOCAL_RC"
        echo "PROJDIR set to $PROJDIR in $LOCAL_RC"
    fi
else
    echo "PROJDIR already set. Skipping."
fi

# ── Done ──────────────────────────────────────────────────────────────────
echo
echo "========================================"
echo " Setup complete!"
echo "========================================"
echo
echo "Next steps:"
echo "  1. Restart your shell or run: source $SHELLRC"
[[ -d "$NVIM_CONFIG_DIR" ]] && echo "  2. Run 'nvim' to install plugins via lazy.nvim"
echo
echo "To install/manage CLI tools later:"
echo "  bash $DOTFILES/bash/install_plugins_refactored.sh"
echo "  bash $DOTFILES/bash/install_plugins_claude.sh"
