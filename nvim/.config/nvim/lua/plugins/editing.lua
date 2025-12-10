return {
    {
        "kylechui/nvim-surround",
        version = "*",
        keys = {
            -- Add surround
            { "ys", mode = "n", desc = "Add surround" },
            { "yss", mode = "n", desc = "Add surround for line" },
            { "yS", mode = "n", desc = "Add surround on new lines" },
            { "ySS", mode = "n", desc = "Add surround on new lines (line)" },

            -- Delete surround
            { "ds", mode = "n", desc = "Delete surround" },

            -- Change surround
            { "cs", mode = "n", desc = "Change surround" },

            -- Visual mode
            { "S", mode = "v", desc = "Add surround (visual)" },
        },
        config = function()
            require("nvim-surround").setup()
        end,
    },
    {
        "kawre/neotab.nvim",
        event = "InsertEnter",
        opts = {},
    },
}
