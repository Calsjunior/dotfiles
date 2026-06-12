return {
	{
		"danymat/neogen",
		opts = {
			enabled = true,
			languages = {
				cpp = {
					template = {
						annotation_convention = "doxygen",
					},
				},
			},
		},
		keys = {
			{
				"<leader>cD",
				function()
					require("neogen").generate()
				end,
				desc = "Generate annotation",
			},
			{
				"<leader>cH",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "Generate File Header",
			},
		},
	},
}
