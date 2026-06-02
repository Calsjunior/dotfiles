return {
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        opts = {},
    },
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
