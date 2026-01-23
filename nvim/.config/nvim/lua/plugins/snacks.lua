return {
    "folke/snacks.nvim",
    keys = {
        { "<leader>e", false },
        { "<leader>E", false },
        { "<leader>fe", false },
        { "<leader>fE", false },
        { "<leader>ft", false },
        { "<leader>fT", false },
        { "<leader><space>", false },
        { "<leader>ff", false },
        { "<leader>fF", false },
        { "<leader>fg", false },
        { "<leader>/", false },
        { "<leader>sg", false },
        { "<leader>sG", false },
    },
    opts = {
        explorer = { enabled = false },
        indent = { scope = { enabled = false } },
        terminal = {
            win = {
                style = "terminal",
                wo = { winhighlight = "Normal:SnacksTerminalNormal,NormalNC:SnacksTerminalNormalNC" },
            },
        },
        picker = {
            matcher = { frecency = true },
            enabled = true,
            sources = {
                files = {
                    cmd = "fd",
                    args = {
                        "--color=never",
                        "--type",
                        "f",
                        "--hidden",
                        "--follow",
                        "--exclude",
                        ".git",
                        "--no-ignore",
                    },
                },
                grep = {
                    cmd = "rg",
                    args = {
                        "--follow",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                    },
                },
                projects = {
                    dev = { "~/Projects", "~/Documents" },
                    win = {
                        input = {
                            keys = {
                                ["<C-x>"] = { "delete_projects", mode = { "n", "i" } },
                            },
                        },
                    },
                },
            },
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
        },
        dashboard = {
            enabled = true,
            preset = {
                header = [[
███▄▄▄▄      ▄████████  ▄██████▄   ▄█    █▄   ▄█    ▄▄▄▄███▄▄▄▄   
███▀▀▀██▄   ███    ███ ███    ███ ███    ███ ███  ▄██▀▀▀███▀▀▀██▄ 
███   ███   ███    █▀  ███    ███ ███    ███ ███▌ ███   ███   ███ 
███   ███  ▄███▄▄▄     ███    ███ ███    ███ ███▌ ███   ███   ███ 
███   ███ ▀▀███▀▀▀     ███    ███ ███    ███ ███▌ ███   ███   ███ 
███   ███   ███    █▄  ███    ███ ███    ███ ███  ███   ███   ███ 
███   ███   ███    ███ ███    ███ ███    ███ ███  ███   ███   ███ 
 ▀█   █▀    ██████████  ▀██████▀   ▀██████▀  █▀    ▀█   ███   █▀  
                ]],
                keys = {
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                    },
                    {
                        icon = " ",
                        key = "r",
                        desc = "Recent Files",
                        action = ":lua Snacks.dashboard.pick('oldfiles')",
                    },
                    { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
                },
                { section = "startup" },
            },
        },
        image = {
            enabled = true,
            doc = {
                enabled = true,
                inline = true,
            },
        },
    },
}
