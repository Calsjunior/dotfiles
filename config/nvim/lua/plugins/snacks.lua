local BLOCKED_PATH = vim.fn.stdpath("state") .. "/hidden_projects.json"
local memory_blocked = nil
local last_mtime = 0

---@return table<string, boolean>
local function load_blocked()
  local stat = vim.uv.fs_stat(BLOCKED_PATH)
  if not stat then
    memory_blocked = {}
    last_mtime = 0
    return memory_blocked
  end

  if memory_blocked and stat.mtime.sec == last_mtime then
    return memory_blocked
  end

  local content = table.concat(vim.fn.readfile(BLOCKED_PATH), "")
  local ok, tbl = pcall(vim.json.decode, content)
  memory_blocked = ok and type(tbl) == "table" and tbl or {}
  last_mtime = stat.mtime.sec
  return memory_blocked
end

---@param blocked table<string, boolean>
local function save_blocked(blocked)
  memory_blocked = blocked
  vim.fn.writefile({ vim.json.encode(blocked) }, BLOCKED_PATH)
  local stat = vim.uv.fs_stat(BLOCKED_PATH)
  if stat then
    last_mtime = stat.mtime.sec
  end
end

---@param path string
---@return string
local function normalize_dir(path)
  local dir = vim.fn.fnamemodify(path, ":p")
  return dir:sub(-1) ~= "/" and dir .. "/" or dir
end

local function init_project_history()
  local ok, recent = pcall(require, "snacks.picker.source.recent")
  if ok then
    local real = recent.projects
    recent.projects = function(opts, ctx)
      local blocked = load_blocked()
      local inner = real(opts, ctx)
      return function(cb)
        inner(function(item)
          if not blocked[normalize_dir(item.file)] then
            cb(item)
          end
        end)
      end
    end
  end

  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(args)
      if vim.bo[args.buf].buftype ~= "" then
        return
      end

      local file = vim.api.nvim_buf_get_name(args.buf)
      if file == "" then
        return
      end

      local blocked = load_blocked()
      if vim.tbl_isempty(blocked) then
        return
      end

      local normalized = vim.fn.fnamemodify(file, ":p")
      local changed = false

      for dir in pairs(blocked) do
        if normalized:sub(1, #dir) == dir then
          blocked[dir] = nil
          changed = true
        end
      end

      if changed then
        save_blocked(blocked)
      end
    end,
  })
end

local function patch_gh_squash()
  vim.schedule(function()
    local ok, gh_actions = pcall(require, "snacks.gh.actions")
    if ok and gh_actions.cli_actions and gh_actions.cli_actions.gh_squash then
      gh_actions.cli_actions.gh_squash.on_submit = function(body, ctx)
        body = body:gsub("%*%*", "")

        for i, arg in ipairs(ctx.args) do
          if arg == "--subject" then
            local pr_suffix = " (#" .. ctx.item.number .. ")"
            if not ctx.args[i + 1]:match("%(#%d+%)$") then
              ctx.args[i + 1] = ctx.args[i + 1] .. pr_suffix
            end
            break
          end
        end

        return body
      end
    end
  end)
end

local function snacks_init()
  init_project_history()
  patch_gh_squash()
end

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
  init = snacks_init,
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
        delete_projects = function(picker, _)
          Snacks.picker.actions.close(picker)
          local items = picker:selected({ fallback = true })
          if #items == 0 then
            return
          end

          local blocked = load_blocked()
          for _, item in ipairs(items) do
            blocked[normalize_dir(item.file)] = true
          end
          save_blocked(blocked)

          Snacks.notify.info("Deleted " .. #items .. " project(s).")
          Snacks.picker.projects()
        end,
      },
    },
    dashboard = {
      enabled = vim.env.KITTY_SCROLLBACK_NVIM ~= "true",
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
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
          { icon = " ", key = "s", desc = "Recent Sessions", action = "<leader>qS" },
        },
        { section = "startup" },
      },
    },
    image = {
      enabled = true,
      doc = { enabled = false, inline = true },
    },
  },
}
