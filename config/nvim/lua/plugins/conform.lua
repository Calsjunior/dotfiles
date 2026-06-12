return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			python = { "ruff_format" },
			lua = { "stylua" },
			html = { "biome-check" },
			css = { "biome-check" },
			javascript = { "biome-check" },
			typescript = { "biome-check" },
			json = { "biome-check" },
			jsonc = { "biome-check" },
			sh = { "shfmt" },
			nix = { "nixfmt" },
		},
	},
}
