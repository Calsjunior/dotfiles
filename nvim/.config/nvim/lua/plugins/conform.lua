return {
    "stevearc/conform.nvim",
    opts = {
        formatters = {
            clang_format = {
                prepend_args = { "--style=file" },
            },
            stylua = {
                prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
            },
            shfmt = {
                prepend_args = { "-i", "4", "-ci" },
            },
            biome = {
                command = "biome",
                args = {
                    "format",
                    "--stdin-file-path",
                    "$FILENAME",
                    "--indent-style=space",
                    "--indent-width=4",
                    "--line-width=120",
                },
                stdin = true,
            },
            ruff_format = {
                command = "ruff",
                args = { "format", "--line-length", "120", "--stdin-filename", "$FILENAME" },
                stdin = true,
            },
            ruff_fix = {
                command = "ruff",
                args = { "check", "--fix", "--stdin-filename", "$FILENAME" },
                stdin = true,
            },
            djlint = {
                command = "djlint",
                args = {
                    "--reformat",
                    "--max-attribute-length",
                    "120",
                    "--max-line-length",
                    "60",
                    "--max-blank-lines",
                    "1",
                    "--preserve-blank-lines",
                    "--custom-blocks",
                    "for,endfor,block,endblock",
                    "-",
                },
                stdin = true,
            },
        },
        formatters_by_ft = {
            c = { "clang-format" },
            cpp = { "clang-format" },
            python = { "ruff_format" },
            lua = { "stylua" },
            htmldjango = { "djlint" },
            css = { "biome" },
            javascript = { "biome" },
            typescript = { "biome" },
            json = { "biome" },
            jsonc = { "biome" },
            sh = { "shfmt" },
        },
    },
}
