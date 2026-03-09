-- blink.cmp v1.9.x introduced a regression where its internal <Esc> handling
-- intercepts the escape character during `norm` commands (e.g. `g/pattern/norm Itext ^[f.r:`),
-- causing subsequent lines to break. The issue exists regardless of whether
-- <Esc> is mapped in the keymap config or not, meaning blink intercepts it
-- internally. Pinned to v1.8.x until this is fixed upstream.
-- Bugged with flash.nvim on version 1.9.x

return {
    "saghen/blink.cmp",
    version = "1.8.*",
    opts = {
        completion = {
            accept = { auto_brackets = { enabled = false } },
            menu = {
                auto_show = false,
                max_height = 10,
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            transform_items = function(_, items)
                return items
            end,
            min_keyword_length = 1,
        },
        keymap = {
            preset = "default",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-CR>"] = { "select_and_accept", "fallback" },

            ["<Esc>"] = {
                function(cmp)
                    cmp.cancel()
                    vim.cmd("stopinsert")
                end,
            },
        },
    },
}
