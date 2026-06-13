return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			folds = { enabled = false },
			servers = {
				html = {},
				cssls = {},
				nixd = {},
				clangd = {},
				biome = {},
				emmet_language_server = {
					filetypes = { "html", "css" },
				},
				ts_ls = {
					handlers = {
						["textDocument/publishDiagnostics"] = function() end,
					},
				},
			},
		},
	},
}
