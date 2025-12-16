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
        picker = {
            enabled = true,
            actions = {
                delete_projects = function(picker, _)
                    Snacks.picker.actions.close(picker)
                    local items = picker:selected({ fallback = true })

                    vim.schedule(function()
                        local shada_path = vim.fn.stdpath("state") .. "/shada/main.shada"
                        local saved_lazyredraw = vim.o.lazyredraw
                        vim.o.lazyredraw = true
                        vim.cmd("silent! edit " .. shada_path)

                        local buf = vim.api.nvim_get_current_buf()
                        local deleted_count = 0

                        for _, item in ipairs(items) do
                            local regex = "^\\S\\(\\n\\s\\|[^\\n]\\)\\{-}"
                                .. vim.fn.escape(item.file, "/\\")
                                .. "\\_.\\{-}\\n*\\ze\\(^\\S\\|\\%$\\)"

                            if pcall(vim.cmd, "silent! %s/" .. regex .. "//g") then
                                deleted_count = deleted_count + 1
                            end
                        end

                        -- Save and clean up
                        vim.cmd("silent! write!")
                        vim.cmd("silent! bwipeout! " .. buf)
                        vim.cmd("silent! rshada!")
                        vim.o.lazyredraw = saved_lazyredraw
                        if deleted_count > 0 then
                            Snacks.notify.info("Deleted " .. deleted_count .. " project(s).")
                        else
                            Snacks.notify.warn("Project not found in history.")
                        end
                        Snacks.picker.projects()
                    end)
                end,
            },
            sources = {
                projects = {
                    win = {
                        input = {
                            keys = {
                                ["<C-x>"] = { "delete_projects", mode = { "n", "i" } },
                            },
                        },
                    },
                },
            },
        },
    },
}
