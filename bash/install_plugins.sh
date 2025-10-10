# fzf
read -p "Install fzf? (y/n) " -n 1 fzf
echo
if [[ $fzf == "y" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# Linux Homebrew
read -p "Install Linux Homebrew? (y/n)" -n 1 brew
echo
if [[ $brew == "y" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# autojump
read -p "Install autojump? (y/n) " -n 1 aj
echo 
if [[ $aj == "y" ]]; then
    python3 -m pip install --user autojump
    if [[ $? -eq 0 ]]; then
        [[ -s $(python3 -m site --user-base)/etc/profile.d/autojump.sh ]] && \
          . $(python3 -m site --user-base)/etc/profile.d/autojump.sh
    else
        (
            git clone https://github.com/wting/autojump.git ~/.autojump
            cd ~/.autojump
            ./install.py
            cat >> ~/.bashrc <<-'EOF' [[ -s ~/.local/etc/profile.d/autojump.sh ]] && \
              . ~/.local/etc/profile.d/autojump.sh
              EOF
        )
    fi
fi
# TODO: zoxide
# TODO: bashmarks
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

read -p "Install ollama? (y/n) " -n 1 ollama
echo
if [[ $ollama == "y" ]]; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

read -p "Install Oh My Tmux? (y/n) " -n 1 omt
echo
if [[ $omt == "y" ]]; then
    curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
fi

read -p "Install bottom? (y/n) " -n 1 bottom
echo
if [[ $bottom == "y" ]]; then
    (
        source ~/.cargo/env
        cargo install bottom
    )
fi

read -p "Create tools env of conda? (y/n) " -n 1 conda_tools
echo
if [[ $conda_tools == "y" ]]; then
    (
        conda create -n tools
        echo 'export PATH='"$CONDA_PREFIX"'/bin:$PATH' >> ~/.bashrc
    )
fi

read -p "Install btop? (y/n) " -n 1 btop
echo
if [[ $btop == "y" ]]; then
    (
        conda activate tools
        mamba install btop
    )
fi

read -p "Instal atop? (y/n) " -n 1 atop
echo
if [[ $atop == "y" ]]; then
    (
        cd $HOME
        wget https://www.atoptool.nl/download/atop-2.12.1.tar.gz
        cd atop-2.12.1
        make
        mkdir -p ~/.local/bin
        cp atop ~/.local/bin/
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
