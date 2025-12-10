return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            folds = { enabled = false },
            servers = {
                pyright = {
                    mason = false,
                    autostart = false,
                },
                html = {
                    filetypes = { "html", "htmldjango", "jinja", "jinga2" },
                    settings = {
                        html = {
                            format = {
                                enabled = true,
                                indentInnerHtml = true,
                                -- indentHandlebars = true,
                                templating = true,
                            },
                        },
                    },
                },
                clangd = {
                    cmd = {
                        "clangd",
                        "--header-insertion=never",
                    },
                },
            },
        },
    },
}
