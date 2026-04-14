return {
    "saghen/blink.cmp",
    dependencies = {
        "mikavilpas/blink-ripgrep.nvim",
    },
    opts = {
        completion = {
            accept = { auto_brackets = { enabled = false } },
            menu = {
                auto_show = true,
                max_height = 10,
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
            transform_items = function(_, items)
                return items
            end,
            min_keyword_length = 1,
            providers = {
                ripgrep = {
                    module = "blink-ripgrep",
                    name = "Ripgrep",
                },
            },
        },
        keymap = {
            preset = "default",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        },
    },
}
