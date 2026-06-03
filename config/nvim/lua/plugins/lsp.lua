return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            folds = { enabled = false },
            servers = {
                emmet_language_server = {
                    filetypes = { "html", "css" },
                },
                ts_ls = {
                    handlers = {
                        ["textDocument/publishDiagnostics"] = function() end,
                    },
                },
                nil_ls = {
                    settings = {
                        ['nil'] = {
                            formatting = {
                                command = { "nixfmt" }
                            },
                        },
                    },
                },
            },
        },
    },
}
