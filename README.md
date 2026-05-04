# Dotfiles

## Quick start (new machine)

```bash
git clone https://github.com/ciaochiaociao/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash setup.sh
```

`setup.sh` will:
1. Source shell config (bash or zsh) — aliases, prompt, etc.
2. Set up vim — source `vimrc.vim`, install plugins
3. Set up neovim — symlink `init.lua`, install lazy.nvim
4. Set up tmux — oh-my-tmux + custom `tmux.conf.local`
5. Set up ctags config
6. Install Nerd Fonts (brew on macOS, manual on Linux)
7. Install CLI tools — batch selector or Claude-powered installer
8. Set project directory

## Install CLI tools only

```bash
# Interactive batch installer (select by number, supports install + uninstall)
bash bash/install_plugins.sh

# Claude-powered installer (requires claude CLI — delegates to Claude as the UI)
bash bash/install_plugins_claude.sh
```

## Structure

```
setup.sh                          # Unified entry point
bash/
  common_aliases.sh               # Shell-agnostic aliases (sourced by bash and zsh)
  bashrc.sh                       # Bash-specific config (prompt, history, completion)
  install_plugins.sh              # Batch CLI tool installer (install + uninstall)
  install_plugins_claude.sh       # Claude-powered CLI tool installer
  install_fonts.sh                # Nerd Fonts installer (Linux)
vim/
  vimrc.vim                       # Vim config
  init.lua                        # Neovim config (lazy.nvim + LSP + telescope + etc.)
  install_plugins.sh              # Vim 8 native plugin installer
tmux/
  install.sh                      # oh-my-tmux bootstrap + symlinks
  tmux.conf.local                 # Custom tmux overrides
others/
  .ctags                          # ctags config
legacy/
  setup_bash.sh                   # Old bash-only setup (replaced by setup.sh)
  setup_zsh.sh                    # Old zsh-only setup (replaced by setup.sh)
  setup_vim                       # Old apt-based vim installer
  install_plugins.sh              # Old one-by-one plugin installer
  install_vim.md                  # Build vim from source instructions
```
