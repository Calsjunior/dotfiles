return {
	{
		"nvim-mini/mini.pairs",
		config = function()
			require("mini.pairs").setup()
		end,
	},
	{
		"nvim-mini/mini.align",
		keys = {
			{ "ga", mode = { "n", "v" } },
			{ "gA", mode = { "n", "v" } },
		},
		opts = function()
			local align = require("mini.align")
			return {
				modifiers = {
					["d"] = function(steps, _)
						table.insert(steps.pre_justify, align.gen_step.filter("n <= 4"))
					end,
				},
			}
		end,
	},
	{
		"nvim-mini/mini.surround",
		keys = {
			{ "gsa", mode = { "n", "v" } },
			{ "gsd", mode = { "n", "v" } },
			{ "gsr", mode = { "n", "v" } },
			{ "gsf", mode = { "n", "v" } },
			{ "gsF", mode = { "n", "v" } },
			{ "gsh", mode = { "n", "v" } },
		},
		opts = {
			mappings = {
				add = "gsa",
				delete = "gsd",
				replace = "gsr",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
			},
		},
	},
}
