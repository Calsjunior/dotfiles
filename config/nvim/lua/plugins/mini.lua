return {
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
}
