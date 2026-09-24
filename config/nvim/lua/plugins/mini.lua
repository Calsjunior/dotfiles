-- stylua: ignore start
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- General workflow ==========================================================
now(function() require("mini.sessions").setup({ autoread = false, autowrite = true }) end)

now_if_args(function()
  local MiniMisc = require("mini.misc")
  MiniMisc.setup()
  MiniMisc.setup_restore_cursor()
  -- NOTE: for nix-flakes where direnv is used, this will attempt to load
  -- flake.nix then .envrc as root first incase of monorepo with multiple
  -- flakes, and .envrc files
  MiniMisc.setup_auto_root({ "flake.nix", ".envrc", ".git" })
end)

-- Appearance ================================================================
now(function()
  require("mini.icons").setup()
  later(MiniIcons.mock_nvim_web_devicons)
end)

now(function()
  local starter = require("mini.starter")
  starter.setup({
    footer = "",
    items = {
      starter.sections.sessions(8, true),
      starter.sections.recent_files(8, false, false),
      starter.sections.builtin_actions(),
    },
  })
end)

now(function()
  local predicate = function(notif)
    if not (notif.data.source == "lsp_progress" and notif.data.client_name == "lua_ls") then
      return true
    end
    -- Filter out some LSP progress notifications from 'lua_ls'
    return notif.msg:find("Diagnosing") == nil and notif.msg:find("semantic tokens") == nil
  end
  local custom_sort = function(notif_arr)
    return require("mini.notify").default_sort(vim.tbl_filter(predicate, notif_arr))
  end
  require("mini.notify").setup({ content = { sort = custom_sort } })
end)

now(function()
  require("mini.statusline").setup({
    content = {
      active = function()
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local git           = MiniStatusline.section_git({ trunc_width = 40 })
        local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
        local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
        local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
        local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
        local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
        local location      = MiniStatusline.section_location({ trunc_width = 75 })
        local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })
        local recording     = vim.fn.reg_recording()
        local macro         = recording ~= "" and ("REC @" .. recording) or ""

        return MiniStatusline.combine_groups({
          { hl = mode_hl,                  strings = { mode } },
          { hl = "MiniStatuslineDevinfo",  strings = { git, diff, diagnostics, lsp } },
          "%<",
          { hl = "MiniStatuslineFilename", strings = { filename } },
          "%=",
          { hl = "MiniStatuslineFilename", strings = { macro } },
          "%#MiniStatuslineFilename#%( %S %)",
          { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
          { hl = mode_hl,                  strings = { search, location } },
        })
      end
    },
  })
end)

now(function() require("mini.tabline").setup() end)

-- Deferred Setup ============================================================

-- Text editing ==============================================================
now_if_args(function() require("mini.completion").setup() end)

later(function() require("mini.pairs").setup() end)

later(function() require("mini.move").setup() end)

later(function() require("mini.align").setup() end)

later(function()
  require("mini.surround").setup({
    custom_surroundings = {
      t = {
        input = { "<()%-?[%w_:]+()[^>]*>.-</()%-?[%w_:]+()>" },
        output = function()
          local tag = MiniSurround.user_input("Tag name")
          if tag == nil then return nil end
          return { left = tag, right = tag }
        end,
      },
    },
  })
end)

later(function() require("mini.bracketed").setup() end)

later(function() require("mini.cmdline").setup() end)

later(function() require("mini.jump").setup() end)

later(function()
  local jump2d = require("mini.jump2d")
  jump2d.setup({ spotter = jump2d.gen_spotter.pattern("[^%s%p]+"), view = { dim = true } })
end)

later(function()
  local ai = require("mini.ai")
  ai.setup({
    custom_textobjects = {
      t = false,
      e = { { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" }, "^().*()$" } },
  })
end)

later(function()
  local snippets = require("mini.snippets")
  snippets.setup({ snippets = { snippets.gen_loader.from_lang() } })
  snippets.start_lsp_server({ match = false })
end)

later(function()
  require("mini.operators").setup()
  vim.keymap.set("n", "(", "<Cmd>normal gxiagxila<CR>", { desc = "Move arg left" })
  vim.keymap.set("n", ")", "<Cmd>normal gxiagxina<CR>", { desc = "Move arg right" })
end)

later(function()
  require("mini.keymap").setup()
  local map_multistep = require("mini.keymap").map_multistep
  local pmenu_cancel = { -- Handle accept with ctrl-y only
    condition = function() return vim.fn.pumvisible() == 1 end,
    action = function() return "<C-e>" .. _G.MiniPairs.cr() end,
  }
  map_multistep("i", "<C-y>",   { "pmenu_accept" })
  map_multistep("c", "<C-y>",   { "pmenu_accept" })
  map_multistep("i", "<CR>",    { pmenu_cancel, "minipairs_cr" })
  map_multistep("i", "<BS>",    { "minipairs_bs", "hungry_bs" })
  map_multistep("i", "<Tab>",   { "minisnippets_next", "jump_after_close" })
  map_multistep("i", "<S-Tab>", { "minisnippets_prev", "jump_before_open" })
end)

-- General workflow ==========================================================
later(function() require("mini.pick").setup({ mappings = { choose_marked = "<C-q>" } }) end)

later(function() require("mini.visits").setup() end)

later(function() require("mini.extra").setup() end)

later(function() require("mini.bufremove").setup() end)

later(function() require("mini.git").setup() end)

later(function() require("mini.diff").setup({ view = { style = "sign" } }) end)

-- Mini Clue =================================================================
later(function()
  local miniclue = require("mini.clue")
  miniclue.setup({
    window = {
      delay = 400,
      config = function(buf_id)
        local max_height = 15
        local num_lines = vim.api.nvim_buf_line_count(buf_id)
        local height = math.min(max_height, num_lines)
        return { anchor = "SE", row = "auto", col = "auto", height = height }
      end,
    },
    triggers = {
      { mode = { "n", "x" }, keys = "<leader>" },
      { mode = { "n", "x" }, keys = "<localleader>" },
      { mode =   "i",        keys = "<C-x>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "[" },
      { mode = { "n", "x" }, keys = "]" },
      { mode =   "n",        keys = "'" },
      { mode =   "n",        keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = { "n", "x" }, keys = "z" },
      { mode = { "n", "x" }, keys = "s" },
    },
    clues = {
      Config.leader_group_clues,

      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end)

-- Appearance ================================================================
later(function() require("mini.cursorword").setup() end)

later(function()
  local animate = require("mini.animate")
  local last_scroll_time = 0
  local is_repeat = false
  animate.setup({
    cursor = { enable = false },
    resize = { enable = false },
    open   = { enable = false },
    close  = { enable = false },
    scroll = {
      timing = function(step)
        if step == 1 then
          local now_time = vim.uv.hrtime() / 1e6
          is_repeat = (now_time - last_scroll_time) <= 100
          last_scroll_time = now_time
        end
        return is_repeat and 5 or 10
      end,

      subscroll = animate.gen_subscroll.equal({ max_output_steps = 20 }),
    },
  })
end)

later(function()
  local indent = require("mini.indentscope")
  indent.setup({
    symbol = "│",
    draw = { delay = 0, animation = indent.gen_animation.none() },
    options = { try_as_border = true },
  })
end)

later(function()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack  = { pattern = "%f[%w]()HACK()%f[%W]", group  = "MiniHipatternsHack" },
      todo  = { pattern = "%f[%w]()TODO()%f[%W]", group  = "MiniHipatternsTodo" },
      note  = { pattern = "%f[%w]()NOTE()%f[%W]", group  = "MiniHipatternsNote" },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)
-- stylua: ignore end
