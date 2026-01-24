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
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            folds = { enabled = false },
            servers = {
                html = {
                    filetypes = { "html", "htmldjango", "jinja", "jinga2" },
                    settings = {
                        html = {
                            format = {
                                wrapLineLength = 160,
                                extraLiners = "",
                                indentInnerHtml = true,
                                templating = true,
                            },
                        },
                    },
                },
                emmet_language_server = { "html", "css", "javascript", "javascriptreact", "typescriptreact" },
                docker_language_server = {
                    filetypes = { "yaml" },
                },
            },
        },
    },
}
