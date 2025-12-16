return {
    -- Theme
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "f4z3r/gruvbox-material.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "habamax",
        },
        config = function(_, opts)
            require("lazyvim").setup(opts)
            local status, _ = pcall(require, "config.current_theme")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    icons_enabled = true,
                },
            })
        end,
    },
}
