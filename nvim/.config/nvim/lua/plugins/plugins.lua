return {
    { "neanias/everforest-nvim", lazy = false, priority = 1000 },
    { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
    { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
    { "catppuccin/nvim", lazy = false, priority = 1000 },
    {
        "LazyVim/LazyVim",
        opts = { colorscheme = "habamax" },
        config = function(_, opts)
            require("lazyvim").setup(opts)
            local status, _ = pcall(require, "config.current_theme")
        end,
    },
    { "nvim-lualine/lualine.nvim" },
    { "kylechui/nvim-surround" },
    { "kawre/neotab.nvim" },
    { "mikavilpas/yazi.nvim" },
    { "MeanderingProgrammer/render-markdown.nvim" },
    { "yousefhadder/markdown-plus.nvim" },
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shfmt",
                "clangd",
                "clang-format",
                "biome",
                "html-lsp",
                "css-lsp",
                "ruff",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            folds = { enabled = false },
            servers = {
                pyright = { mason = false, autostart = false },
                html = {
                    filetypes = { "html", "htmldjango", "jinja", "jinga2" },
                    settings = { html = { format = { enabled = true, indentInnerHtml = true, templating = true } } },
                },
            },
        },
    },
}
