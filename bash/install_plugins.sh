# fzf
read -p "Install fzf? (y/n) " -n 1 rust
echo
if [[ $ans == "y" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# Rust / Cargo
read -p "Install Rust / Cargo? (y/n) " -n 1 rust
echo
[[ $rust == "y" ]] && (cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh)

# AIChat
read -p "Install aichat? (y/n) " -n 1 aichat
echo
if [[ $aichat == "y" ]]; then
    (
        source ~/.cargo/env
        cargo install aichat 
    )
fi

# z
read -p "Install z? (y/n) " -n 1 z
echo
if [[ $z == "y" ]]; then
    git clone https://github.com/rupa/z.git ~/z
    echo '. ~/z/z.sh' >> ~/.bashrc
fi

# fd
read -p "Install fd? (y/n) " -n 1 fd
echo
if [[ $fd == "y" ]]; then

    (
        source ~/.cargo/env
        cargo install fd-find
    )
fi

# jq

read -p "Install jq? (y/n) " -n 1 jq
echo
if [[ $jq == "y" ]]; then
    (
        mkdir -p ~/.local
        cd ~/.local
        if command -v dpkg > /dev/null 2>&1 && \\
            command -v apt > /dev/null 2>&1; then
            apt download jq
            dpkg -x jq_*_$(dpkg --print-architecture).deb .
        fi
        if command -v yum > /dev/null 2>&1; then
            yum download jq
            rpm2cpio jq_*.rpm | cpio -idmv
        fi
    )
fi

# PATH
case :$PATH: in
    *:"$HOME/.local/usr/bin":*)
        ;;
    *)
        export PATH="$HOME/.local/usr/bin:$PATH"
        ;;
esac
