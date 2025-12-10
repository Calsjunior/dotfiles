-- Change Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- QOL options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 5
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.guicursor =
    "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor"

-- Disable netrw
vim.g.loaded_netrwPlugin = 1
