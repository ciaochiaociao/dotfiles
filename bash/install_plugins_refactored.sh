#!/bin/bash

# Detect OS and shell
OS="$(uname -s)"
ARCH="$(uname -m)"
CURRENT_SHELL="$(basename "$SHELL")"
SHELLRC="$HOME/.${CURRENT_SHELL}rc"  # ~/.bashrc or ~/.zshrc

# Portable download helper: prefer curl (available on macOS+Linux), fall back to wget
download() {
    local url="$1"
    local output="$2"
    if command -v curl &>/dev/null; then
        if [[ -n "$output" ]]; then
            curl -fsSL -o "$output" "$url"
        else
            curl -fsSL "$url"
        fi
    elif command -v wget &>/dev/null; then
        if [[ -n "$output" ]]; then
            wget -q -O "$output" "$url"
        else
            wget -q -O- "$url"
        fi
    else
        echo "Error: neither curl nor wget found" >&2
        return 1
    fi
}

# Tracking arrays for installation report
SUMMARY_INSTALLED=()
SUMMARY_SKIPPED=()
SUMMARY_FAILED=()

# Utility function to prompt user and execute installation function
install_if_confirmed() {
    local tool_name="$1"
    local install_function="$2"
    local check_target="$3"
    
    local is_installed=false
    
    if [[ -n "$check_target" ]]; then
        # Check if argument starts with ~ or / (path check)
        if [[ "$check_target" == ~* ]] || [[ "$check_target" == /* ]]; then
            local full_path="${check_target/#\~/$HOME}"
            if [[ -e "$full_path" ]]; then
                is_installed=true
            fi
        else
            # Command check
            if command -v "$check_target" &> /dev/null; then
                is_installed=true
            fi
        fi
    fi
    
    if $is_installed; then
        echo "$tool_name is already installed ('$check_target' found). Skipping."
        SUMMARY_INSTALLED+=("$tool_name (already present)")
        return
    fi
    
    read -p "Install $tool_name? (y/n) " -n 1 response
    echo
    if [[ $response == "y" ]]; then
        if $install_function; then
             SUMMARY_INSTALLED+=("$tool_name (newly installed)")
        else
             SUMMARY_FAILED+=("$tool_name")
        fi
    else
        SUMMARY_SKIPPED+=("$tool_name (skipped by user)")
    fi
}

# Cargo-based installation helper
install_cargo_package() {
    local package="$1"
    (
        [[ -f ~/.cargo/env ]] && source ~/.cargo/env
        cargo install "$package"
    )
}

# Mamba-based installation helper (for tools conda environment)
install_mamba_package() {
    local package="$1"
    mamba install -n tools -y "$package"
}

# Installation functions for each tool
install_fzf() {
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

install_homebrew() {
    /bin/bash -c "$(download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Linux Homebrew needs PATH setup
    if [[ "$OS" == "Linux" && -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$SHELLRC"
    fi
}

install_miniforge() {
    local installer="Miniforge3-${OS}-${ARCH}.sh"
    download "https://github.com/conda-forge/miniforge/releases/latest/download/${installer}" "$installer"
    bash "$installer" -b
    rm -f "$installer"
    ~/miniforge3/bin/conda init "$CURRENT_SHELL"

    # Source conda to make conda/mamba available immediately
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
        conda activate base
    fi
}

install_rust() {
    command -v cargo &>/dev/null || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_aichat() {
    install_cargo_package "aichat"
}

install_z() {
    git clone https://github.com/rupa/z.git ~/z
    echo '. ~/z/z.sh' >> "$SHELLRC"
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
            cat >> "$SHELLRC" <<-'EOF'
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
    if [[ "$OS" == "Darwin" ]]; then
        brew install jq
    else
        (
            mkdir -p ~/.local
            cd ~/.local
            if command -v dpkg &>/dev/null && command -v apt &>/dev/null; then
                apt download jq
                dpkg -x jq_*_$(dpkg --print-architecture).deb .
            elif command -v yum &>/dev/null; then
                yum download jq
                rpm2cpio jq_*.rpm | cpio -idmv
            else
                echo "No supported package manager found for jq" >&2
                return 1
            fi
        )
    fi
}

install_ollama() {
    download https://ollama.com/install.sh | sh
}

install_oh_my_tmux() {
    download "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
}

install_bottom() {
    install_cargo_package "bottom"
}

install_conda_tools() {
    (
        conda create -n tools -y
        echo 'export PATH="$HOME/miniforge3/envs/tools/bin:$PATH"' >> "$SHELLRC"
    )
}

install_btop() {
    install_mamba_package "btop"
}

install_htop() {
    install_mamba_package "htop"
}

install_atop() {
    if [[ "$OS" == "Darwin" ]]; then
        brew install atop
    else
        (
            cd "$HOME"
            local version="2.12.1"
            download "https://www.atoptool.nl/download/atop-${version}.tar.gz" "atop-${version}.tar.gz"
            tar -xzf "atop-${version}.tar.gz"
            cd "atop-${version}"
            make
            mkdir -p ~/.local/bin
            cp atop ~/.local/bin/
            cd "$HOME"
            rm -rf "atop-${version}" "atop-${version}.tar.gz"
        )
    fi
}

install_rg() {
    install_cargo_package "ripgrep"
}

install_fselect() {
    install_cargo_package "fselect"
}

install_eza() {
    install_cargo_package "eza"
}

install_lsd() {
    install_cargo_package "lsd"
}

install_bat() {
    install_cargo_package "bat"
    mkdir -p ~/.config/bat
    bat --generate-config-file
    echo 'export PAGER="bat"' >> "$SHELLRC"
    git config --global core.pager "bat --paging=always"
    git config --global pager.diff "bat --diff"
    git config --global pager.show "bat --diff"
    cat >> ~/.config/bat/config <<-'EOF'
--theme="TwoDark"
--style="numbers,changes,header"
--paging=auto
EOF
    echo 'export FZF_DEFAULT_COMMAND="fd --type f"' >> "$SHELLRC"
    echo 'export FZF_DEFAULT_OPTS="--preview '\''bat --style=numbers --color=always --line-range :500 {}'\'' --preview-window=right:60%"' >> "$SHELLRC"
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
install_if_confirmed "Miniforge" "install_miniforge" "conda"
install_if_confirmed "fzf" "install_fzf" "fzf"
install_if_confirmed "Homebrew" "install_homebrew" "brew"
install_if_confirmed "Rust / Cargo" "install_rust" "cargo"
install_if_confirmed "aichat" "install_aichat" "aichat"
install_if_confirmed "z" "install_z" "~/z"
install_if_confirmed "autojump" "install_autojump" "autojump"
# TODO: zoxide
# TODO: bashmarks
install_if_confirmed "fd" "install_fd" "fd"
install_if_confirmed "jq" "install_jq" "jq"
install_if_confirmed "ollama" "install_ollama" "ollama"
install_if_confirmed "Oh My Tmux" "install_oh_my_tmux" "~/.tmux"
install_if_confirmed "bottom" "install_bottom" "btm"
install_if_confirmed "tools env of conda" "install_conda_tools" "~/miniforge3/envs/tools"
install_if_confirmed "btop" "install_btop" "btop"
install_if_confirmed "htop" "install_htop" "htop"
install_if_confirmed "atop" "install_atop" "atop"
install_if_confirmed "ripgrep" "install_rg" "rg"
install_if_confirmed "fselect" "install_fselect" "fselect"
install_if_confirmed "eza" "install_eza" "eza"
install_if_confirmed "lsd" "install_lsd" "lsd"
install_if_confirmed "bat" "install_bat" "bat"
install_if_confirmed "nnn" "install_nnn" "nnn"

# Setup PATH
setup_local_path

echo
echo "========================================"
echo "Installation Report"
echo "========================================"
if [ ${#SUMMARY_INSTALLED[@]} -gt 0 ]; then
    echo "Installed / Present:"
    for item in "${SUMMARY_INSTALLED[@]}"; do
        echo "  - $item"
    done
fi

if [ ${#SUMMARY_SKIPPED[@]} -gt 0 ]; then
    echo
    echo "Skipped:"
    for item in "${SUMMARY_SKIPPED[@]}"; do
        echo "  - $item"
    done
fi

if [ ${#SUMMARY_FAILED[@]} -gt 0 ]; then
    echo
    echo "Failed:"
    for item in "${SUMMARY_FAILED[@]}"; do
        echo "  - $item"
    done
fi
echo "========================================"
