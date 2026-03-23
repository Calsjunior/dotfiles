return {
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shfmt",
                "clangd",
                "clang-format",
                "html-lsp",
                "css-lsp",
                "ruff",
                "biome",
                "docker-language-server",
                "emmet-language-server",
                "typescript-language-server",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            folds = { enabled = false },
            servers = {
                emmet_language_server = {
                    filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact" },
                },
                docker_language_server = {
                    filetypes = { "yaml" },
                },
            },
        },
    },
}
