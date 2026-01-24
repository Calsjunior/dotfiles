return {
    { "neanias/everforest-nvim", lazy = false, priority = 1000 },
    { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
    { "catppuccin/nvim", lazy = false, priority = 1000 },
    { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
    {
        "LazyVim/LazyVim",
        opts = { colorscheme = "habamax" },
        config = function(_, opts)
            require("lazyvim").setup(opts)
            local status, _ = pcall(require, "config.current_theme")
        end,
    },
    { "nvim-lualine/lualine.nvim" },
    {
        "kylechui/nvim-surround",
        config = function()
            require("nvim-surround").setup()
        end,
    },
    {
        "kawre/neotab.nvim",
        event = "InsertEnter",
        opts = {
            tabkey = "<Tab>",
            reverse_key = "<S-Tab>",
            act_as_tab = true,
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = {
            check_ts = true,
            ts_config = {
                lua = { "string" },
                javascript = { "template_string" },
            },
        },
    },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                css = { css = true },
            })
        end,
    },
    {
        "mikavilpas/yazi.nvim",
        init = function()
            vim.g.loaded_netrwPlugin = 1
        end,
        event = "VeryLazy",
        opts = {
            open_for_directories = true,
        },
    },
    { "MeanderingProgrammer/render-markdown.nvim" },
    { "yousefhadder/markdown-plus.nvim", ft = "markdown", opts = {} },
    {
        "lambdalisue/suda.vim",
        init = function()
            vim.g.suda_smart_edit = 1
        end,
    },
}
