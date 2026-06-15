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
    scroll = {
      animate = {
        duration = { step = 20, total = 250 },
      },
    },
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
          dev = { "~/dev", "~/Documents" },
          max_depth = 3,
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
        --- Deletes selected projects from the Snacks project picker and Neovim's history.
        ---
        --- To permanently remove a project we must edit the shada file.
        --- First, strip the project's entries from the in-memory
        --- shada buffer via regex, and filter `vim.v.oldfiles` so the picker
        --- reflects the deletion immediately without waiting for any disk I/O.
        --- Second, write the modified shada buffer to disk and reload it.
        --- Writing shada takes time, but since the picker has already
        --- reopened, this runs silently in the background.
        ---@param picker snacks.Picker The active Snacks picker instance.
        ---@param _      any           Unused fallback parameter.
        delete_projects = function(picker, _)
          Snacks.picker.actions.close(picker)
          local items = picker:selected({ fallback = true })
          if #items == 0 then
            return
          end

          vim.schedule(function()
            local shada_path = vim.fn.stdpath("state") .. "/shada/main.shada"
            local buf = vim.fn.bufadd(shada_path)
            vim.fn.bufload(buf)

            -- Strip project entries from the shada buffer in memory safely via Regex
            vim.api.nvim_buf_call(buf, function()
              for _, item in ipairs(items) do
                local regex = "^\\S\\(\\n\\s\\|[^\\n]\\)\\{-}"
                  .. vim.fn.escape(item.file, "/\\")
                  .. "\\_.\\{-}\\n*\\ze\\(^\\S\\|\\%$\\)"
                pcall(vim.cmd, "silent! %s/" .. regex .. "//g")
              end
            end)

            -- Update in-memory oldfiles so the picker updates instantly
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
              for dir in pairs(deleted_dirs) do
                if normalized:sub(1, #dir) == dir then
                  return false
                end
              end
              return true
            end, vim.v.oldfiles)

            Snacks.notify.info("Deleted " .. #items .. " project(s).")
            Snacks.picker.projects()

            vim.defer_fn(function()
              vim.api.nvim_buf_call(buf, function()
                vim.cmd("silent! write!")
              end)
              vim.api.nvim_buf_delete(buf, { force = true })
              vim.cmd("silent! rshada!")
            end, 100)
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
          {
            icon = " ",
            key = "p",
            desc = "Projects",
            action = ":lua Snacks.picker.projects()",
          },
          {
            icon = " ",
            key = "s",
            desc = "Recent Sessions",
            action = "<leader>qS",
          },
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
