vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.statuscolumn = "%s %l %r "
vim.o.signcolumn = "no"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.softtabstop = 3
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.cursorline = true
vim.o.smartcase = true
vim.o.termguicolors = true
vim.o.winborder = "rounded"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
		{src = "https://github.com/neanias/everforest-nvim"},
		{src = "https://github.com/ellisonleao/gruvbox.nvim"},
		{src = "https://github.com/mikavilpas/yazi.nvim"},
		{src = "https://github.com/MeanderingProgrammer/render-markdown.nvim"},
		{src = "https://github.com/YousefHadder/markdown-plus.nvim"},
		{src = "https://github.com/nvim-lualine/lualine.nvim"},
		{src = "https://github.com/akinsho/bufferline.nvim"},
		{src = "https://github.com/kdheepak/lazygit.nvim"},
		{src = "https://github.com/lewis6991/gitsigns.nvim"},
		{src = "https://github.com/kawre/neotab.nvim"},
		{src = "https://github.com/kylechui/nvim-surround"},
		{src = "https://github.com/neovim/nvim-lspconfig"},
		{src = "https://github.com/nvim-treesitter/nvim-treesitter"},

		-- Dependencies
		{src = "https://github.com/nvim-tree/nvim-web-devicons"},
		{src = "https://github.com/nvim-lua/plenary.nvim"},
})

local map = vim.keymap.set

-- General
vim.g.mapleader = ","
map("n", "<leader>o", ":update<CR> :source<CR>")
map("n", "<C-s>", ":write<CR>")
map("n", "<leader>qq", ":quit<CR>")
map("n", "<Esc><Esc>", ":nohlsearch<CR>")

-- Movement
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "H", "_")
map("n", "L", "g$")

-- Plugins
map("n", "<leader>lf", vim.lsp.buf.format)
map("n", "<leader>gg", ":LazyGit<CR>")
map("n", "<leader>e", ":Yazi<CR>")
map("n", "<leader>E", ":Yazi cwd<CR>")

-- Setup
require("current_theme")
require("lualine").setup()
require("bufferline").setup()
require("nvim-surround").setup()
require("neotab").setup()
require("gitsigns").setup()

-- Configuration
vim.lsp.enable({"lua_ls", "clangd"})


-- Autocmd
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, cliend.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.cmd("set completeopt+=noselect")
