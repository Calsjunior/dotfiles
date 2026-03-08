return {
    "saghen/blink.cmp",
    opts = {
        completion = {
            accept = { auto_brackets = { enabled = false } },
            menu = {
                auto_show = false, -- don't auto popup, trigger manually
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

            -- Accept completion
            ["<C-CR>"] = { "select_and_accept", "fallback" },

            -- Close menu
            ["<Esc>"] = {
                function(cmp)
                    if cmp.is_visible() then
                        cmp.cancel()
                    end
                    vim.schedule(function()
                        vim.cmd("stopinsert")
                    end)
                end,
            },
        },
    },
}
