#!/bin/bash

# Claude-powered plugin manager
# Requires: claude CLI (https://claude.ai/claude-code)

if ! command -v claude &>/dev/null; then
    echo "Error: 'claude' CLI not found. Install it first:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Tool list — edit this to add/remove tools
TOOLS="
- Miniforge: conda/mamba package manager — manages Python environments and installs pre-built binary packages. Foundation for the 'tools' conda env below. Install via official shell installer.
- fzf: general-purpose fuzzy finder — interactive filtering for files, command history, git branches, etc. Powers Ctrl-R history search and file pickers. Install via git clone to ~/.fzf.
- Homebrew: cross-platform package manager — works on macOS and Linux. Useful fallback when cargo/mamba don't have a package. Install via official script.
- Rust / Cargo: Rust toolchain and package manager — needed to install many modern CLI tools below. Install via rustup.
- aichat: AI chat in the terminal — supports OpenAI, Claude, local models. Useful for quick LLM queries without leaving the shell. Install via cargo.
- z: frecency-based directory jumper — tracks your most-used directories, 'z foo' jumps to the most frecent match. Lightweight alternative to autojump. Install via git clone to ~/z.
- autojump: learning directory jumper — similar to z but with a Python backend, supports tab completion of partial paths. Install via pip or git clone + install.py --destdir ~/.local.
- fd: modern 'find' replacement — faster, respects .gitignore, colorized output, simpler syntax (e.g. 'fd pattern' vs 'find . -name pattern'). Cargo package name: fd-find. Install via cargo.
- jq: JSON processor — pipe JSON through it to filter, transform, and pretty-print. Essential for working with APIs and config files. Install via brew (macOS) or apt/yum (Linux).
- ollama: local LLM runner — run Llama, Mistral, and other models locally. Useful for offline AI, experimentation, and privacy-sensitive tasks. Install via official script.
- Oh My Tmux: tmux configuration framework — sensible defaults, status bar, mouse support, vim-style bindings out of the box. Install via official script.
- bottom: graphical system monitor (command: btm) — TUI process/CPU/memory/network/disk viewer with graphs. Rust alternative to htop with more visualizations. Install via cargo (package: bottom).
- Conda tools env: dedicated conda environment for mamba-installed CLI tools — keeps tool binaries isolated from your base Python environment. Prerequisite for btop/htop/nnn below.
- btop: resource monitor with a polished TUI — shows CPU, memory, disks, network, and processes with a modern UI. More visual than htop. Install via mamba into tools env.
- htop: interactive process viewer — classic 'top' replacement with color, scrolling, tree view, and mouse support. Install via mamba into tools env.
- atop: advanced system monitor with history — records system-level metrics (CPU, memory, disk I/O, network) over time for post-mortem analysis. Install via brew (macOS) or build from source (Linux).
- ripgrep: extremely fast recursive grep (command: rg) — respects .gitignore, searches compressed files, supports PCRE2 regex. 10-100x faster than grep on large codebases. Install via cargo.
- fselect: SQL-like file finder — query files with SQL syntax (e.g. 'fselect name, size from . where size > 1M'). Useful for complex file searches. Install via cargo.
- eza: modern ls replacement — colorized output, git status integration, tree view, icons. Actively maintained fork of exa. Install via cargo.
- lsd: another modern ls replacement — similar to eza with Nerd Font icons, color-coded file types, tree view. Install via cargo.
- bat: cat with wings — syntax highlighting, git integration, line numbers, paging. Drop-in replacement for cat/less. Also integrates with fzf for file previews. Install via cargo.
- nnn: terminal file manager — fast, minimal, scriptable with plugins. Navigate, preview, and manage files without leaving the terminal. Install via mamba into tools env.
"

SYSTEM_PROMPT="You are a plugin manager for a developer's dotfiles setup.

## Machine info
- OS: $(uname -s)
- Arch: $(uname -m)
- Shell: $(basename "$SHELL")
- Shell RC file: \$HOME/.$(basename "$SHELL")rc

## Tools to manage
${TOOLS}

## Your job
1. First, detect which of the above tools are already installed. Use 'command -v' for CLI tools or check paths for directory-based tools (e.g. ~/z, ~/.fzf, ~/.tmux, ~/miniforge3/envs/tools).
2. Present a clear status table showing each tool and whether it's installed or missing.
3. Ask the user what they want to install or uninstall. Accept comma-separated numbers, ranges (e.g. 1,3,5-7), or 'all'.
4. For each selected action:
   - Install or uninstall as appropriate for this platform
   - Verify success by checking the command/path exists (or doesn't) afterward
   - Report the result
5. At the end, show a summary of what was installed, uninstalled, and any failures.

## Platform rules
- On macOS: prefer brew for system tools (jq, atop), curl over wget
- On Linux: use apt/dnf/yum as available, or build from source
- For Rust tools: use 'cargo install <package>'
- For conda/mamba tools: install into the 'tools' conda environment
- Shell config lines go into the correct RC file (~/.bashrc or ~/.zshrc)
- Prefer ~/.local for manual installs (keeps \$HOME clean)
- Always verify after install: run the command or check the path

## Important
- Be concise. Don't over-explain.
- Ask before doing anything destructive (uninstall).
- If something fails, diagnose and suggest a fix rather than silently moving on."

exec claude --system-prompt "$SYSTEM_PROMPT" \
    --allowedTools "Bash" \
    "Scan my system and show me the plugin status table. Then ask what I'd like to install or uninstall."
