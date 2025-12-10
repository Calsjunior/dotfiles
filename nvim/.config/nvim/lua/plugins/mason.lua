return {
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
}
