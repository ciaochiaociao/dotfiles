# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Rust / Cargo
read -p "Install Rust / Cargo? (y/n) " rust
[[ $rust == "y" ]] && (cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh)

# AIChat
read -p "Install aichat?" aichat
if [[ $aichat == "y" ]]; then
    (
        source ~/.cargo/env
        cargo install aichat 
    )
fi
