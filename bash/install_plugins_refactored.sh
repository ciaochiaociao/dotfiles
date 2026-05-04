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

# ── Tool registry ──────────────────────────────────────────────────────────
# Each tool is registered as: name|check_target|install_fn|uninstall_fn
# check_target: command name or path (~/... or /...) to test existence
TOOLS=(
    "Miniforge|conda|install_miniforge|uninstall_miniforge"
    "fzf|fzf|install_fzf|uninstall_fzf"
    "Homebrew|brew|install_homebrew|uninstall_homebrew"
    "Rust / Cargo|cargo|install_rust|uninstall_rust"
    "aichat|aichat|install_aichat|uninstall_cargo_aichat"
    "z|~/z|install_z|uninstall_z"
    "autojump|autojump|install_autojump|uninstall_autojump"
    "fd|fd|install_fd|uninstall_cargo_fd"
    "jq|jq|install_jq|uninstall_jq"
    "ollama|ollama|install_ollama|uninstall_ollama"
    "Oh My Tmux|~/.tmux|install_oh_my_tmux|uninstall_oh_my_tmux"
    "bottom|btm|install_bottom|uninstall_cargo_bottom"
    "Conda tools env|~/miniforge3/envs/tools|install_conda_tools|uninstall_conda_tools"
    "btop|btop|install_btop|uninstall_mamba_btop"
    "htop|htop|install_htop|uninstall_mamba_htop"
    "atop|atop|install_atop|uninstall_atop"
    "ripgrep|rg|install_rg|uninstall_cargo_rg"
    "fselect|fselect|install_fselect|uninstall_cargo_fselect"
    "eza|eza|install_eza|uninstall_cargo_eza"
    "lsd|lsd|install_lsd|uninstall_cargo_lsd"
    "bat|bat|install_bat|uninstall_cargo_bat"
    "nnn|nnn|install_nnn|uninstall_mamba_nnn"
)

# ── Check if a tool is installed ───────────────────────────────────────────
is_tool_installed() {
    local check_target="$1"
    if [[ -z "$check_target" ]]; then
        return 1
    fi
    if [[ "$check_target" == ~* ]] || [[ "$check_target" == /* ]]; then
        local full_path="${check_target/#\~/$HOME}"
        [[ -e "$full_path" ]]
    else
        command -v "$check_target" &>/dev/null
    fi
}

# ── Cargo helpers ──────────────────────────────────────────────────────────
install_cargo_package() {
    local package="$1"
    (
        [[ -f ~/.cargo/env ]] && source ~/.cargo/env
        cargo install "$package"
    )
}

uninstall_cargo_package() {
    local package="$1"
    (
        [[ -f ~/.cargo/env ]] && source ~/.cargo/env
        cargo uninstall "$package"
    )
}

# ── Mamba helpers ──────────────────────────────────────────────────────────
install_mamba_package() {
    local package="$1"
    mamba install -n tools -y "$package"
}

uninstall_mamba_package() {
    local package="$1"
    mamba remove -n tools -y "$package"
}

# ── Install functions ──────────────────────────────────────────────────────

install_fzf() {
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
}

install_homebrew() {
    NONINTERACTIVE=1 /bin/bash -c "$(download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
        conda activate base
    fi
}

install_rust() {
    command -v cargo &>/dev/null || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

install_aichat() { install_cargo_package "aichat"; }

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
            local tmpdir
            tmpdir="$(mktemp -d)"
            git clone https://github.com/wting/autojump.git "$tmpdir"
            cd "$tmpdir"
            ./install.py --destdir ~/.local
            rm -rf "$tmpdir"
            cat >> "$SHELLRC" <<-'EOF'
[[ -s ~/.local/etc/profile.d/autojump.sh ]] && \
  . ~/.local/etc/profile.d/autojump.sh
EOF
        )
    fi
}

install_fd() { install_cargo_package "fd-find"; }

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

install_ollama() { download https://ollama.com/install.sh | sh; }

install_oh_my_tmux() {
    download "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
}

install_bottom() { install_cargo_package "bottom"; }

install_conda_tools() {
    (
        conda create -n tools -y
        echo 'export PATH="$HOME/miniforge3/envs/tools/bin:$PATH"' >> "$SHELLRC"
    )
}

install_btop() { install_mamba_package "btop"; }
install_htop() { install_mamba_package "htop"; }

install_atop() {
    if [[ "$OS" == "Darwin" ]]; then
        echo "atop is Linux-only (requires /proc and kernel process accounting). Skipping."
        return 1
    fi
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
}

install_rg() { install_cargo_package "ripgrep"; }
install_fselect() { install_cargo_package "fselect"; }
install_eza() { install_cargo_package "eza"; }
install_lsd() { install_cargo_package "lsd"; }

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

install_nnn() { install_mamba_package "nnn"; }

# ── Uninstall functions ────────────────────────────────────────────────────

uninstall_fzf() {
    ~/.fzf/uninstall 2>/dev/null
    rm -rf ~/.fzf
}

uninstall_homebrew() {
    /bin/bash -c "$(download https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
}

uninstall_miniforge() {
    rm -rf ~/miniforge3
    echo "Note: you may want to remove conda init lines from $SHELLRC"
}

uninstall_rust() {
    rustup self uninstall
}

uninstall_cargo_aichat() { uninstall_cargo_package "aichat"; }

uninstall_z() {
    rm -rf ~/z
    echo "Note: remove '. ~/z/z.sh' from $SHELLRC"
}

uninstall_autojump() {
    python3 -m pip uninstall -y autojump 2>/dev/null
    rm -f ~/.local/bin/autojump
    rm -rf ~/.local/share/autojump
    rm -f ~/.local/etc/profile.d/autojump.sh
    rm -f ~/.local/share/man/man1/autojump.1
    echo "Note: remove autojump lines from $SHELLRC"
}

uninstall_cargo_fd() { uninstall_cargo_package "fd-find"; }

uninstall_jq() {
    if [[ "$OS" == "Darwin" ]]; then
        brew uninstall jq
    else
        rm -f ~/.local/usr/bin/jq
        echo "Note: jq may have other files under ~/.local — check manually"
    fi
}

uninstall_ollama() {
    if [[ "$OS" == "Darwin" ]]; then
        rm -rf /usr/local/bin/ollama ~/.ollama
    else
        sudo rm -f /usr/local/bin/ollama
        sudo rm -rf /usr/share/ollama
        echo "Note: remove ollama service if installed (systemctl)"
    fi
}

uninstall_oh_my_tmux() {
    rm -rf ~/.tmux
    rm -f ~/.tmux.conf ~/.tmux.conf.local
}

uninstall_cargo_bottom() { uninstall_cargo_package "bottom"; }

uninstall_conda_tools() {
    conda env remove -n tools -y
    echo "Note: remove tools PATH line from $SHELLRC"
}

uninstall_mamba_btop() { uninstall_mamba_package "btop"; }
uninstall_mamba_htop() { uninstall_mamba_package "htop"; }

uninstall_atop() {
    if [[ "$OS" == "Darwin" ]]; then
        echo "atop is Linux-only — nothing to uninstall."
        return 1
    fi
    rm -f ~/.local/bin/atop
}

uninstall_cargo_rg() { uninstall_cargo_package "ripgrep"; }
uninstall_cargo_fselect() { uninstall_cargo_package "fselect"; }
uninstall_cargo_eza() { uninstall_cargo_package "eza"; }
uninstall_cargo_lsd() { uninstall_cargo_package "lsd"; }

uninstall_cargo_bat() {
    uninstall_cargo_package "bat"
    rm -rf ~/.config/bat
    echo "Note: remove bat-related exports from $SHELLRC and git config"
}

uninstall_mamba_nnn() { uninstall_mamba_package "nnn"; }

# ── PATH setup ─────────────────────────────────────────────────────────────
setup_local_path() {
    case :$PATH: in
        *:"$HOME/.local/usr/bin":*)
            ;;
        *)
            export PATH="$HOME/.local/usr/bin:$PATH"
            ;;
    esac
}

# ── Interactive menu ───────────────────────────────────────────────────────

# Parse a selection string like "1,3,5-7" into PARSED_SELECTION (0-based indices)
parse_selection() {
    local input="$1"
    local max="$2"
    PARSED_SELECTION=()

    # Split on commas and spaces
    IFS=', ' read -ra tokens <<< "$input"
    for token in "${tokens[@]}"; do
        if [[ "$token" == *-* ]]; then
            local start="${token%-*}"
            local end="${token#*-}"
            for (( i=start; i<=end; i++ )); do
                if (( i >= 1 && i <= max )); then
                    PARSED_SELECTION+=($((i - 1)))
                fi
            done
        elif [[ "$token" =~ ^[0-9]+$ ]]; then
            if (( token >= 1 && token <= max )); then
                PARSED_SELECTION+=($((token - 1)))
            fi
        fi
    done
}

main() {
    local total=${#TOOLS[@]}
    local names=() checks=() install_fns=() uninstall_fns=() statuses=()
    local installed_indices=() missing_indices=()

    # Parse registry and detect status
    for i in "${!TOOLS[@]}"; do
        IFS='|' read -r name check inst uninst <<< "${TOOLS[$i]}"
        names+=("$name")
        checks+=("$check")
        install_fns+=("$inst")
        uninstall_fns+=("$uninst")

        if is_tool_installed "$check"; then
            statuses+=("installed")
            installed_indices+=("$i")
        else
            statuses+=("missing")
            missing_indices+=("$i")
        fi
    done

    # Display status table
    echo "========================================"
    echo " Plugin Manager  (${OS} / ${CURRENT_SHELL})"
    echo "========================================"
    printf "  %-4s %-13s %s\n" "#" "Status" "Tool"
    echo "  ---- ------------- --------------------"
    for i in "${!names[@]}"; do
        local num=$((i + 1))
        if [[ "${statuses[$i]}" == "installed" ]]; then
            printf "  %-4s \033[32m%-13s\033[0m %s\n" "$num" "[installed]" "${names[$i]}"
        else
            printf "  %-4s \033[33m%-13s\033[0m %s\n" "$num" "[missing]" "${names[$i]}"
        fi
    done
    echo "========================================"
    echo

    # ── Install prompt ─────────────────────────────────────────────────
    if [[ ${#missing_indices[@]} -gt 0 ]]; then
        local missing_nums=()
        for idx in "${missing_indices[@]}"; do missing_nums+=($((idx + 1))); done
        echo "Missing: ${missing_nums[*]}"
        echo -n "Install: enter numbers (e.g. 1,3,5-7), 'all' for all missing, or Enter to skip: "
        read install_input

        local to_install=()
        if [[ "$install_input" == "all" ]]; then
            to_install=("${missing_indices[@]}")
        elif [[ -n "$install_input" ]]; then
            parse_selection "$install_input" "$total"
            to_install=("${PARSED_SELECTION[@]}")
        fi
    else
        echo "All tools are already installed!"
        local to_install=()
    fi

    # ── Uninstall prompt ───────────────────────────────────────────────
    if [[ ${#installed_indices[@]} -gt 0 ]]; then
        local installed_nums=()
        for idx in "${installed_indices[@]}"; do installed_nums+=($((idx + 1))); done
        echo "Installed: ${installed_nums[*]}"
        echo -n "Uninstall: enter numbers (e.g. 2,4), or Enter to skip: "
        read uninstall_input

        local to_uninstall=()
        if [[ "$uninstall_input" == "all" ]]; then
            to_uninstall=("${installed_indices[@]}")
        elif [[ -n "$uninstall_input" ]]; then
            parse_selection "$uninstall_input" "$total"
            to_uninstall=("${PARSED_SELECTION[@]}")
        fi
    else
        local to_uninstall=()
    fi

    # ── Confirm ────────────────────────────────────────────────────────
    if [[ ${#to_install[@]} -eq 0 && ${#to_uninstall[@]} -eq 0 ]]; then
        echo "Nothing to do."
        return
    fi

    echo
    if [[ ${#to_install[@]} -gt 0 ]]; then
        echo "Will INSTALL:"
        for idx in "${to_install[@]}"; do
            echo "  + ${names[$idx]}"
        done
    fi
    if [[ ${#to_uninstall[@]} -gt 0 ]]; then
        echo "Will UNINSTALL:"
        for idx in "${to_uninstall[@]}"; do
            echo "  - ${names[$idx]}"
        done
    fi
    echo
    read -p "Proceed? (y/n) " -n 1 confirm
    echo
    [[ "$confirm" != "y" ]] && { echo "Aborted."; return; }

    # ── Execute ────────────────────────────────────────────────────────
    local result_installed=() result_uninstalled=() result_failed=()

    for idx in "${to_install[@]}"; do
        echo
        echo ">> Installing ${names[$idx]}..."
        if ${install_fns[$idx]}; then
            result_installed+=("${names[$idx]}")
        else
            result_failed+=("${names[$idx]} (install)")
        fi
    done

    for idx in "${to_uninstall[@]}"; do
        echo
        echo ">> Uninstalling ${names[$idx]}..."
        if ${uninstall_fns[$idx]}; then
            result_uninstalled+=("${names[$idx]}")
        else
            result_failed+=("${names[$idx]} (uninstall)")
        fi
    done

    # ── Setup PATH ─────────────────────────────────────────────────────
    setup_local_path

    # ── Report ─────────────────────────────────────────────────────────
    echo
    echo "========================================"
    echo " Results"
    echo "========================================"
    if [[ ${#result_installed[@]} -gt 0 ]]; then
        echo "Installed:"
        for item in "${result_installed[@]}"; do echo "  + $item"; done
    fi
    if [[ ${#result_uninstalled[@]} -gt 0 ]]; then
        echo "Uninstalled:"
        for item in "${result_uninstalled[@]}"; do echo "  - $item"; done
    fi
    if [[ ${#result_failed[@]} -gt 0 ]]; then
        echo "Failed:"
        for item in "${result_failed[@]}"; do echo "  ! $item"; done
    fi
    echo "========================================"
}

main
