return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
        labels = "asdfghjklqwertyuiopzxcvbnm",
        label = {
            distance = true,
        },
    },
    keys = {
        {
            "s",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump({
                    search = { max_length = 2 },
                    jump = { autojump = true },
                    label = {
                        min_pattern_length = 2,
                    },
                })
            end,
            desc = "Flash (Smart Filtering)",
        },
        {
            "S",
            mode = { "n", "o", "x" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter",
        },
    },
}
