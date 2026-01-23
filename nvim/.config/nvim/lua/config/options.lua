vim.g.mapleader = ","

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Visual settings
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.pumheight = 10 -- Pop up menu height

-- File handling
vim.opt.undofile = true
vim.opt.swapfile = false

-- Behavior settings
vim.opt.hidden = true
vim.opt.backspace = "indent,eol,start" -- Better backspace behavior
vim.opt.clipboard = "unnamedplus"

-- Cursor settings
vim.opt.guicursor =
    "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
