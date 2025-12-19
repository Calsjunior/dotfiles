vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.statuscolumn = "%s %l %r "
vim.o.signcolumn = "no"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.cursorline = true
vim.o.smartcase = true
vim.o.termguicolors = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ","
local map = vim.keymap.set
map("n", "<leader>o", ":update<CR> :source<CR>")
map("n", "<C-s>", ":write<CR>")
map("n", "<leader>qq", ":quit<CR>")
map("n", "<Esc><Esc>", ":nohlsearch<CR>")

map("n", "j", "gj")
map("n", "k", "gk")
map("n", "H", "_")
map("n", "L", "g$")

map("n", "<leader>lf", vim.lsp.buf.format)
map("n", "<leader>f", ":Pick files<CR>")

vim.pack.add({
		{src = "https://github.com/neanias/everforest-nvim"},
		{src = "https://github.com/ellisonleao/gruvbox.nvim"},
		{src = "https://github.com/mikavilpas/yazi.nvim"},
		{src = "https://github.com/MeanderingProgrammer/render-markdown.nvim"},
		{src = "https://github.com/YousefHadder/markdown-plus.nvim"},
		{src = "https://github.com/nvim-lualine/lualine.nvim"},
		{src = "https://github.com/akinsho/bufferline.nvim"},
		{src = "https://github.com/echasnovski/mini.pick"},
		{src = "https://github.com/kdheepak/lazygit.nvim"},
		{src = "https://github.com/kawre/neotab.nvim"},
		{src = "https://github.com/kylechui/nvim-surround"},
		{src = "https://github.com/neovim/nvim-lspconfig"},

		-- Dependencies
		{src = "https://github.com/nvim-lua/plenary.nvim"},
		{src = "https://github.com/nvim-mini/mini.icons"},
})

require "mini.pick".setup()
require("current_theme")

vim.lsp.enable({"lua_ls"})

map("n", "<leader>e", function()
  require("yazi").yazi()
end)

map("n", "<leader>E", function()
    require("yazi").yazi(nil, vim.fn.getcwd())
end)
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    require("yazi").setup({
      open_for_directories = true,
    })
  end,
})
