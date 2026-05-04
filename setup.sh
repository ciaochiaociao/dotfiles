#!/bin/bash
set -e

# ── Detect environment ────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"
CURRENT_SHELL="$(basename "$SHELL")"
SHELLRC="$HOME/.${CURRENT_SHELL}rc"
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"

# ── Status tracking ───────────────────────────────────────────────────────
declare -a STATUS_NAMES=()
declare -a STATUS_STATES=()

record_status() {
    STATUS_NAMES+=("$1")
    STATUS_STATES+=("$2")
}

# ── Helpers ────────────────────────────────────────────────────────────────
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

# ── Pre-flight status check ───────────────────────────────────────────────
check_status() {
    echo "========================================"
    echo " Dotfiles Setup"
    echo "========================================"
    echo " OS:       $OS ($ARCH)"
    echo " Shell:    $CURRENT_SHELL ($SHELLRC)"
    echo " Dotfiles: $DOTFILES"
    echo "========================================"
    echo
    echo " Current status:"

    # Shell config
    if already_has "dotfiles/bash/common_aliases.sh" "$SHELLRC" 2>/dev/null; then
        printf "   \033[32m[done]\033[0m    Shell config sourced in $SHELLRC\n"
    else
        printf "   \033[33m[missing]\033[0m  Shell config not in $SHELLRC\n"
    fi

    # Vim
    if command -v vim &>/dev/null; then
        if already_has "dotfiles/vim/vimrc.vim" ~/.vimrc 2>/dev/null; then
            printf "   \033[32m[done]\033[0m    Vim config (vimrc.vim sourced)\n"
        else
            printf "   \033[33m[missing]\033[0m  Vim config (vimrc.vim not sourced)\n"
        fi
        if [[ -d "$HOME/.vim/pack/plugins/start/gruvbox" ]]; then
            printf "   \033[32m[done]\033[0m    Vim plugins\n"
        else
            printf "   \033[33m[missing]\033[0m  Vim plugins\n"
        fi
    else
        printf "   \033[90m[skip]\033[0m    Vim (not installed)\n"
    fi

    # Neovim
    if command -v nvim &>/dev/null; then
        if [[ -L "$NVIM_CONFIG_DIR/init.lua" ]]; then
            printf "   \033[32m[done]\033[0m    Neovim config (init.lua symlinked)\n"
        elif [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
            printf "   \033[33m[warn]\033[0m    Neovim config (init.lua exists but not symlinked)\n"
        else
            printf "   \033[33m[missing]\033[0m  Neovim config\n"
        fi
        if [[ -d "$LAZY_DIR" ]]; then
            printf "   \033[32m[done]\033[0m    lazy.nvim plugin manager\n"
        else
            printf "   \033[33m[missing]\033[0m  lazy.nvim plugin manager\n"
        fi
    else
        printf "   \033[90m[skip]\033[0m    Neovim (not installed)\n"
    fi

    # Tmux
    if command -v tmux &>/dev/null; then
        if [[ -d "$HOME/.config/tmux/oh-my-tmux" ]]; then
            printf "   \033[32m[done]\033[0m    Tmux (oh-my-tmux configured)\n"
        else
            printf "   \033[33m[missing]\033[0m  Tmux config\n"
        fi
    else
        printf "   \033[90m[skip]\033[0m    Tmux (not installed)\n"
    fi

    # ctags
    if [[ -f ~/.ctags ]] || [[ -f ~/.ctags.d/default.ctags ]]; then
        printf "   \033[32m[done]\033[0m    ctags config\n"
    elif command -v ctags &>/dev/null; then
        printf "   \033[33m[missing]\033[0m  ctags config\n"
    else
        printf "   \033[90m[skip]\033[0m    ctags (not installed)\n"
    fi

    # Fonts
    if [[ "$OS" == "Darwin" ]]; then
        if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null 2>&1; then
            printf "   \033[32m[done]\033[0m    Nerd Fonts\n"
        else
            printf "   \033[33m[missing]\033[0m  Nerd Fonts\n"
        fi
    elif [[ "$OS" == "Linux" ]]; then
        if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
            printf "   \033[32m[done]\033[0m    Nerd Fonts\n"
        else
            printf "   \033[33m[missing]\033[0m  Nerd Fonts\n"
        fi
    fi

    # Project dir
    local local_rc="$HOME/scripts/${CURRENT_SHELL}rc.sh"
    if already_has "PROJDIR" "$local_rc" 2>/dev/null; then
        printf "   \033[32m[done]\033[0m    Project directory\n"
    else
        printf "   \033[33m[missing]\033[0m  Project directory\n"
    fi

    echo "========================================"
    echo
}

# ── Show pre-flight status ─────────────────────────────────────────────────
check_status

if ! ask "Proceed with setup?"; then
    echo "Aborted."
    exit 0
fi

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
            record_status "Shell config" "configured"
        else
            record_status "Shell config" "already done"
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
            record_status "Shell config" "configured"
        else
            record_status "Shell config" "already done"
        fi
        ;;
    *)
        echo "Unsupported shell: $CURRENT_SHELL (only bash and zsh are supported)"
        echo "Skipping shell config. You can manually source ~/dotfiles/bash/common_aliases.sh"
        record_status "Shell config" "skipped (unsupported shell)"
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
    fi

    echo "Installing vim plugins..."
    bash "$DOTFILES/vim/install_plugins.sh"
    record_status "Vim" "configured"
else
    echo "vim not found. Skipping."
    record_status "Vim" "skipped (not installed)"
fi

# ── 3. Neovim ──────────────────────────────────────────────────────────────
step "Neovim"

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
    if [[ ! -d "$LAZY_DIR" ]]; then
        echo "Installing lazy.nvim..."
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
    else
        echo "lazy.nvim already installed."
    fi

    record_status "Neovim" "configured"
else
    echo "nvim not found."
    if ask "Would you like to install neovim?"; then
        if command -v brew &>/dev/null; then
            brew install neovim
        else
            echo "Please install Homebrew first, or install neovim manually: https://neovim.io"
        fi
        # Re-run nvim setup if install succeeded
        if command -v nvim &>/dev/null; then
            mkdir -p "$NVIM_CONFIG_DIR"
            ln -sf "$DOTFILES/vim/init.lua" "$NVIM_CONFIG_DIR/init.lua"
            [[ ! -d "$LAZY_DIR" ]] && git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
            record_status "Neovim" "installed + configured"
        else
            record_status "Neovim" "failed to install"
        fi
    else
        record_status "Neovim" "skipped"
    fi
fi

# ── 4. Tmux ────────────────────────────────────────────────────────────────
step "Tmux"

if command -v tmux &>/dev/null; then
    bash "$DOTFILES/tmux/install.sh"
    record_status "Tmux" "configured"
else
    echo "tmux not found."
    if ask "Would you like to install tmux?"; then
        if command -v brew &>/dev/null; then
            brew install tmux
        else
            echo "Please install Homebrew first, or install tmux manually."
        fi
        if command -v tmux &>/dev/null; then
            bash "$DOTFILES/tmux/install.sh"
            record_status "Tmux" "installed + configured"
        else
            record_status "Tmux" "failed to install"
        fi
    else
        record_status "Tmux" "skipped"
    fi
fi

# ── 5. ctags ───────────────────────────────────────────────────────────────
step "ctags config"

if [[ ! -f ~/.ctags ]] && [[ ! -f ~/.ctags.d/default.ctags ]]; then
    if command -v ctags &>/dev/null; then
        if ctags --version 2>/dev/null | grep -q "Universal"; then
            mkdir -p ~/.ctags.d
            ln -sf "$DOTFILES/others/.ctags" ~/.ctags.d/default.ctags
            echo "Symlinked ~/.ctags.d/default.ctags"
        else
            ln -sf "$DOTFILES/others/.ctags" ~/.ctags
            echo "Symlinked ~/.ctags"
        fi
        record_status "ctags" "configured"
    else
        echo "ctags not found. Skipping."
        record_status "ctags" "skipped (not installed)"
    fi
else
    echo "ctags config already exists. Skipping."
    record_status "ctags" "already done"
fi

# ── 6. Fonts ──────────────────────────────────────────────────────────────
step "Nerd Fonts"

if [[ "$OS" == "Darwin" ]]; then
    if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null 2>&1; then
        echo "JetBrains Mono Nerd Font already installed. Skipping."
        record_status "Nerd Fonts" "already done"
    elif ask "Install JetBrains Mono Nerd Font?"; then
        brew install --cask font-jetbrains-mono-nerd-font
        record_status "Nerd Fonts" "installed"
    else
        record_status "Nerd Fonts" "skipped"
    fi
elif [[ "$OS" == "Linux" ]]; then
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        echo "JetBrains Mono Nerd Font already installed. Skipping."
        record_status "Nerd Fonts" "already done"
    elif ask "Install JetBrains Mono Nerd Font?"; then
        bash "$DOTFILES/bash/install_fonts.sh"
        record_status "Nerd Fonts" "installed"
    else
        record_status "Nerd Fonts" "skipped"
    fi
fi

# ── 7. CLI tools ──────────────────────────────────────────────────────────
step "CLI tools"

echo "Choose how to install CLI tools:"
echo "  1) Interactive batch installer (install_plugins.sh)"
echo "  2) Claude-powered installer (requires claude CLI)"
echo "  3) Skip"
read -p "Choice [1/2/3]: " -n 1 tools_choice
echo

case "$tools_choice" in
    1)
        bash "$DOTFILES/bash/install_plugins.sh"
        record_status "CLI tools" "ran batch installer"
        ;;
    2)
        bash "$DOTFILES/bash/install_plugins_claude.sh"
        record_status "CLI tools" "ran Claude installer"
        ;;
    3)
        echo "Skipping CLI tools."
        record_status "CLI tools" "skipped"
        ;;
    *)
        echo "Invalid choice. Skipping."
        record_status "CLI tools" "skipped"
        ;;
esac

# ── 8. Claude Code ────────────────────────────────────────────────────────
step "Claude Code statusline"

CLAUDE_DIR="$HOME/.claude"
if [[ -d "$CLAUDE_DIR" ]]; then
    if [[ -L "$CLAUDE_DIR/statusline-command.sh" ]]; then
        echo "Statusline already symlinked. Skipping."
        record_status "Claude statusline" "already done"
    elif [[ -e "$CLAUDE_DIR/statusline-command.sh" ]]; then
        echo "WARNING: $CLAUDE_DIR/statusline-command.sh exists but is not a symlink."
        echo "Back it up and re-run, or manually symlink:"
        echo "  ln -sf $DOTFILES/claude/statusline-command.sh $CLAUDE_DIR/statusline-command.sh"
        record_status "Claude statusline" "skipped (existing file)"
    else
        ln -sf "$DOTFILES/claude/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
        echo "Symlinked $CLAUDE_DIR/statusline-command.sh -> $DOTFILES/claude/statusline-command.sh"
        record_status "Claude statusline" "configured"
    fi
else
    echo "~/.claude not found. Skipping (Claude Code not installed?)."
    record_status "Claude statusline" "skipped (no ~/.claude)"
fi

# ── 9. Project directory ──────────────────────────────────────────────────
step "Project directory"

LOCAL_RC="$HOME/scripts/${CURRENT_SHELL}rc.sh"
if ! already_has "PROJDIR" "$LOCAL_RC"; then
    read -p "Set your project directory (or Enter to skip): " PROJDIR
    if [[ -n "$PROJDIR" ]]; then
        echo "export PROJDIR=\"$PROJDIR\"" >> "$LOCAL_RC"
        echo "PROJDIR set to $PROJDIR in $LOCAL_RC"
        record_status "Project directory" "set to $PROJDIR"
    else
        record_status "Project directory" "skipped"
    fi
else
    echo "PROJDIR already set. Skipping."
    record_status "Project directory" "already done"
fi

# ── Final report ──────────────────────────────────────────────────────────
echo
echo "========================================"
echo " Setup Results"
echo "========================================"
for i in "${!STATUS_NAMES[@]}"; do
    local_state="${STATUS_STATES[$i]}"
    case "$local_state" in
        *"already"*|*"configured"*|*"installed"*|*"set to"*|*"ran"*)
            printf "  \033[32m✓\033[0m %-20s %s\n" "${STATUS_NAMES[$i]}" "$local_state" ;;
        *"skipped"*)
            printf "  \033[33m–\033[0m %-20s %s\n" "${STATUS_NAMES[$i]}" "$local_state" ;;
        *"failed"*)
            printf "  \033[31m✗\033[0m %-20s %s\n" "${STATUS_NAMES[$i]}" "$local_state" ;;
    esac
done
echo "========================================"
echo
echo "Next steps:"
echo "  1. Restart your shell or run: source $SHELLRC"
if command -v nvim &>/dev/null; then
    echo "  2. Run 'nvim' to install plugins via lazy.nvim"
fi
echo
echo "To install/manage CLI tools later:"
echo "  bash $DOTFILES/bash/install_plugins.sh"
echo "  bash $DOTFILES/bash/install_plugins_claude.sh"
