local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })
            require("telescope").load_extension("fzf")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight")
        end,
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            input = { enabled = true },
        },
    },
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = true,
        keys = {
            { "<leader>a",  nil,                              desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file from tree",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
            },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
        },
    },
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Tmux/Window left" },
            { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Tmux/Window down" },
            { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Tmux/Window up" },
            { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Tmux/Window right" },
            { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Tmux/Window previous" },
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                window = { width = 30 },
                filesystem = {
                    follow_current_file = { enabled = true },
                    use_libuv_file_watcher = true,
                },
            })
        end,
    },
})


require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd" }
})

-- ===== Ported from vimrc.vim =====

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Search statistics messages
vim.opt.shortmess:remove("S")

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Timeout for mapped sequences
vim.opt.timeoutlen = 300

-- Indentation
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true

-- Mouse
vim.opt.mouse = "a"

-- File searching
vim.opt.path:append("**")

-- Autocompletion
vim.opt.wildmenu = true
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.git", "*.swp" })
vim.opt.completeopt = { "menu", "menuone" }

-- Tags
vim.opt.tags = "./tags;,tags;"

-- Theme
vim.opt.background = "dark"
pcall(vim.cmd, "colorscheme gruvbox")

-- ripgrep
if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --vimgrep --smart-case"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

-- ===== Key mappings =====
local map = vim.keymap.set

-- Insert mode escape alternatives
map("i", "jk", "<Esc>")
map("i", "kj", "<Esc>")

-- Insert mode arrow movement
map("i", "<C-h>", "<Left>")
map("i", "<C-j>", "<Down>")
map("i", "<C-k>", "<Up>")
map("i", "<C-l>", "<Right>")

-- Toggle mouse
map("n", "<F2>", function()
    if vim.o.mouse == "a" then
        vim.o.mouse = ""
    else
        vim.o.mouse = "a"
    end
end)

-- Toggle wrap
map("n", "<F3>", ":set wrap!<CR>")

-- Toggle relative/number
map("n", "<F4>", ":set relativenumber! number!<CR>")

-- Terminal mode escape
map("t", "<Esc>", [[<C-\><C-n>]])

-- Telescope keymaps
local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files)
map("n", "<leader>fg", builtin.live_grep)
map("n", "<leader>fb", builtin.buffers)
map("n", "<leader>fh", builtin.help_tags)

-- neo-tree (disable netrw so neo-tree handles directory opens)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd("Neotree show")
        end
    end,
})
map("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })

-- lightline
vim.g.lightline = { colorscheme = "gruvbox" }

-- startify
vim.g.startify_lists = {
    { type = "files",     header = { "   Recent Files" } },
    { type = "sessions",  header = { "   Sessions" } },
    { type = "bookmarks", header = { "   Bookmarks" } },
    { type = "commands",  header = { "   Commands" } },
}
vim.g.startify_bookmarks = { "~/.vimrc", "/data/ap5/users/chiahsu/", "/data/ap5/users/chiahsu/trip3_snr" }
vim.g.startify_session_dir = "~/.vim/session"

-- Python syntax highlighting
vim.g.python_highlight_all = 1

-- oscyank (only when no GUI)
if vim.fn.has("gui_running") == 0 then
    map("n", "<leader>y", "<Plug>OSCYankOperator")
    map("n", "<leader>yy", "<leader>y_", { remap = true })
    map("v", "<leader>y", "<Plug>OSCYankVisual")
end

-- Folding
local fold_group = vim.api.nvim_create_augroup("FileTypeFolds", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = fold_group,
    pattern = "python",
    callback = function()
        vim.opt_local.foldmethod = "indent"
        vim.opt_local.foldlevel = 99
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = fold_group,
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.foldmethod = "syntax"
        vim.opt_local.foldlevel = 1
    end,
})
vim.opt.foldenable = true

