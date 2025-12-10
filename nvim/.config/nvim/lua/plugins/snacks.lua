return {
    "folke/snacks.nvim",
    keys = {
        { "<leader>e", false },
        { "<leader>E", false },
        { "<leader>fe", false },
        { "<leader>fE", false },
    },

    opts = {
        explorer = { enabled = false },
        indent = {
            scope = { enabled = false },
        },
        terminal = {
            win = {
                style = "terminal",
                wo = {
                    winhighlight = "Normal:SnacksTerminalNormal,NormalNC:SnacksTerminalNormalNC",
                },
            },
        },
        image = {
            filetypes = {
                "png",
                "jpg",
                "jpeg",
                "gif",
                "bmp",
                "webp",
                "tiff",
                "svg",
            },
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        -- Define custom terminal highlights after setup
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
                local darker_bg = normal.bg and normal.bg - 0x0a0a0a or 0x2d353b

                vim.api.nvim_set_hl(0, "SnacksTerminalNormal", {
                    fg = normal.fg,
                    bg = darker_bg,
                })
                vim.api.nvim_set_hl(0, "SnacksTerminalNormalNC", {
                    fg = normal.fg,
                    bg = darker_bg,
                })
            end,
        })
    end,
}
