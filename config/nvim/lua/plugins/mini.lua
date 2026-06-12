return {
    {
        "nvim-mini/mini.pairs",
        config = function()
            require("mini.pairs").setup()
        end,
    },
    {
        "nvim-mini/mini.align",
        opts = function()
            local align = require("mini.align")

            return {
                mappings = {
                    start = "ga",
                    start_with_preview = "gA",
                },
                modifiers = {
                    ["d"] = function(steps, _)
                        table.insert(steps.pre_justify, align.gen_step.filter("n <= 4"))
                    end,
                },
            }
        end,
    },
}
