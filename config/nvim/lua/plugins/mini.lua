local function load_now()
  -- General workflow ==========================================================
  require("mini.sessions").setup({ autoread = false, autowrite = true })
  local MiniMisc = require("mini.misc")
  MiniMisc.setup()
  MiniMisc.setup_restore_cursor()
  -- NOTE: for nix-flakes where direnv is used, this will attempt to load
  -- flake.nix then .envrc as root first incase of monorepo with multiple
  -- flakes, and .envrc files
  MiniMisc.setup_auto_root({ "flake.nix", ".envrc", ".git" })

  -- Appearance ================================================================
  require("mini.icons").setup()
  require("mini.icons").mock_nvim_web_devicons()
  require("mini.starter").setup()
  require("mini.notify").setup()
  require("mini.statusline").setup()
  require("mini.tabline").setup({ tabpage_section = "none" })
end

local function load_later()
  -- stylua: ignore start
  -- Text editing ==============================================================
  require("mini.pairs").setup()
  require("mini.move").setup()
  require("mini.align").setup()
  require("mini.surround").setup()
  require("mini.bracketed").setup()
  require("mini.snippets").setup()
  require("mini.cmdline").setup()
  require("mini.jump").setup()
  require("mini.jump2d").setup({ view = { dim = true } })
  require("mini.completion").setup()
  require("mini.ai").setup({
    custom_textobjects = {
      e = { { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" }, "^().*()$" } },
  })
  require("mini.keymap").setup()
  local map_multistep = require("mini.keymap").map_multistep
  local pmenu_cancel = { -- Handle accept with ctrl-y only
    condition = function() return vim.fn.pumvisible() == 1 end,
    action = function() return '<C-e>' .. _G.MiniPairs.cr() end,
  }
  map_multistep("i", "<C-y>",   { "pmenu_accept" })
  map_multistep("c", "<C-y>",   { "pmenu_accept" })
  map_multistep("i", "<CR>",    {  pmenu_cancel ,"minipairs_cr" })
  map_multistep("i", "<BS>",    { "minipairs_bs", "hungry_bs" })
  map_multistep("i", "<Tab>",   { "minisnippets_expand", "minisnippets_next", "jump_after_close", })
  map_multistep("i", "<S-Tab>", { "minisnippets_prev", "jump_before_open", })
  -- stylua: ignore end

  -- General workflow ==========================================================
  require("mini.pick").setup({ mappings = { choose_marked = "<C-q>" } })
  require("mini.visits").setup()
  require("mini.extra").setup()
  require("mini.bufremove").setup()
  require("mini.git").setup()
  require("mini.diff").setup({ view = { style = "sign" } })

  -- Mini Clue =================================================================
  local miniclue = require("mini.clue")
  miniclue.setup({
    window = {
      delay = 400,
      config = function(buf_id)
        local max_height = 15
        local num_lines = vim.api.nvim_buf_line_count(buf_id)
        local height = math.min(max_height, num_lines)
        return {
          anchor = "SE",
          row = "auto",
          col = "auto",
          height = height,
        }
      end,
    },
    -- stylua: ignore
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
      require("config.keymaps").leader_group_clues,

      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })

  -- Appearance ================================================================
  require("mini.cursorword").setup()
  local animate = require("mini.animate")
  local last_scroll_time = 0
  local is_repeat = false

  -- stylua: ignore
  animate.setup({
    cursor = { enable = false },
    resize = { enable = false },
    open   = { enable = false },
    close  = { enable = false },
    scroll = {
      timing = function(step)
        if step == 1 then
          local now = vim.uv.hrtime() / 1e6
          is_repeat = (now - last_scroll_time) <= 100
          last_scroll_time = now
        end
        return is_repeat and 5 or 10
      end,

      subscroll = animate.gen_subscroll.equal({ max_output_steps = 20 }),
    },
  })

  local indent = require("mini.indentscope")
  indent.setup({
    symbol = "│",
    draw = { delay = 0, animation = indent.gen_animation.none() },
    options = { try_as_border = true },
  })

  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end

return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    load_now()
    vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = load_later })
  end,
}
