return {
    -- Theme
    {
        "neanias/everforest-nvim",
        config = function()
            require("everforest").setup({
                background = "hard",
            })
            vim.cmd.colorscheme("everforest")
        end,
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "everforest",
        },
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "everforest",
                    icons_enabled = true,
                },
            })
        end,
    },
}
