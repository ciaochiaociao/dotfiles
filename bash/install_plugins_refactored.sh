#!/bin/bash

# Utility function to prompt user and execute installation function
install_if_confirmed() {
    local tool_name="$1"
    local install_function="$2"
    
    read -p "Install $tool_name? (y/n) " -n 1 response
    echo
    if [[ $response == "y" ]]; then
        $install_function
    fi
}

# Cargo-based installation helper
install_cargo_package() {
    local package="$1"
    (
        source ~/.cargo/env
        cargo install "$package"
    )
}

# Mamba-based installation helper (for tools conda environment)
install_mamba_package() {
    local package="$1"
    mamba install -n tools "$package"
}

# Installation functions for each tool
install_fzf() {
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_rust() {
    cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_aichat() {
    install_cargo_package "aichat"
}

install_z() {
    git clone https://github.com/rupa/z.git ~/z
    echo '. ~/z/z.sh' >> ~/.bashrc
}

install_autojump() {
    python3 -m pip install --user autojump
    if [[ $? -eq 0 ]]; then
        [[ -s $(python3 -m site --user-base)/etc/profile.d/autojump.sh ]] && \
          . $(python3 -m site --user-base)/etc/profile.d/autojump.sh
    else
        (
            git clone https://github.com/wting/autojump.git ~/.autojump
            cd ~/.autojump
            ./install.py
            cat >> ~/.bashrc <<-'EOF'
[[ -s ~/.local/etc/profile.d/autojump.sh ]] && \
  . ~/.local/etc/profile.d/autojump.sh
EOF
        )
    fi
}

install_fd() {
    install_cargo_package "fd-find"
}

install_jq() {
    (
        mkdir -p ~/.local
        cd ~/.local
        if command -v dpkg > /dev/null 2>&1 && \
            command -v apt > /dev/null 2>&1; then
            apt download jq
            dpkg -x jq_*_$(dpkg --print-architecture).deb .
        fi
        if command -v yum > /dev/null 2>&1; then
            yum download jq
            rpm2cpio jq_*.rpm | cpio -idmv
        fi
    )
}

install_ollama() {
    curl -fsSL https://ollama.com/install.sh | sh
}

install_oh_my_tmux() {
    curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
}

install_bottom() {
    install_cargo_package "bottom"
}

install_conda_tools() {
    (
        conda create -n tools
        echo 'export PATH='"$CONDA_PREFIX"'/bin:$PATH' >> ~/.bashrc
    )
}

install_btop() {
    install_mamba_package "btop"
}

install_htop() {
    install_mamba_package "htop"
}

install_atop() {
    (
        cd $HOME
        wget https://www.atoptool.nl/download/atop-2.12.1.tar.gz
        tar -xzf atop-2.12.1.tar.gz
        cd atop-2.12.1
        make
        mkdir -p ~/.local/bin
        cp atop ~/.local/bin/
    )
}

install_rg() {
    install_cargo_package "ripgrep"
}

install_fselect() {
    install_cargo_package "fselect"
}

install_exa() {
    install_cargo_package "exa"
}

install_lsd() {
    install_cargo_package "lsd"
}

install_bat() {
    install_cargo_package "bat"
}

install_nnn() {
    install_mamba_package "nnn"
}

# PATH setup function
setup_local_path() {
    case :$PATH: in
        *:"$HOME/.local/usr/bin":*)
            ;;
        *)
            export PATH="$HOME/.local/usr/bin:$PATH"
            ;;
    esac
}

# Main installation prompts
install_if_confirmed "fzf" "install_fzf"
install_if_confirmed "Linux Homebrew" "install_homebrew"
install_if_confirmed "Rust / Cargo" "install_rust"
install_if_confirmed "aichat" "install_aichat"
install_if_confirmed "z" "install_z"
install_if_confirmed "autojump" "install_autojump"
# TODO: zoxide
# TODO: bashmarks
install_if_confirmed "fd" "install_fd"
install_if_confirmed "jq" "install_jq"
install_if_confirmed "ollama" "install_ollama"
install_if_confirmed "Oh My Tmux" "install_oh_my_tmux"
install_if_confirmed "bottom" "install_bottom"
install_if_confirmed "tools env of conda" "install_conda_tools"
install_if_confirmed "btop" "install_btop"
install_if_confirmed "htop" "install_htop"
install_if_confirmed "atop" "install_atop"
install_if_confirmed "ripgrep" "install_rg"
install_if_confirmed "fselect" "install_fselect"
install_if_confirmed "exa" "install_exa"
install_if_confirmed "lsd" "install_lsd"
install_if_confirmed "bat" "install_bat"
install_if_confirmed "nnn" "install_nnn"

# Setup PATH
setup_local_path