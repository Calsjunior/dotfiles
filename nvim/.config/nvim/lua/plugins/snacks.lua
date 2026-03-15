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
                        local buf = vim.fn.bufadd(shada_path)
                        vim.fn.bufload(buf)

                        -- Remove from oldfiles immediately so picker doesn't show it
                        local deleted_dirs = {}
                        for _, item in ipairs(items) do
                            local dir = vim.fn.fnamemodify(item.file, ":p")
                            if dir:sub(-1) ~= "/" then
                                dir = dir .. "/"
                            end
                            deleted_dirs[dir] = true
                        end
                        vim.v.oldfiles = vim.tbl_filter(function(f)
                            local normalized = vim.fn.fnamemodify(f, ":p")
                            for dir, _ in pairs(deleted_dirs) do
                                if normalized:sub(1, #dir) == dir then
                                    return false
                                end
                            end
                            return true
                        end, vim.v.oldfiles)

                        local deleted_count = #items
                        Snacks.notify.info("Deleted " .. deleted_count .. " project(s).")
                        Snacks.picker.projects()

                        -- Write shada in background
                        vim.defer_fn(function()
                            vim.api.nvim_buf_call(buf, function()
                                for _, item in ipairs(items) do
                                    local regex = "^\\S\\(\\n\\s\\|[^\\n]\\)\\{-}"
                                        .. vim.fn.escape(item.file, "/\\")
                                        .. "\\_.\\{-}\\n*\\ze\\(^\\S\\|\\%$\\)"
                                    pcall(vim.cmd, "silent! %s/" .. regex .. "//g")
                                end
                                vim.cmd("silent! write!")
                            end)
                            vim.api.nvim_buf_delete(buf, { force = true })
                            vim.cmd("silent! rshada!")
                        end, 0)
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
                enabled = false,
                inline = true,
            },
        },
    },
}
