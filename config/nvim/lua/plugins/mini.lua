return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    -- Text editing ====================================================================
    -- stylua: ignore start
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
    vim.cmd([[autocmd FileType snacks_picker_input lua vim.b.minicompletion_disable = true]])
    require("mini.ai").setup({
      custom_textobjects = {
        e = { { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" }, "^().*()$" } },
    })
    require("mini.keymap").setup()
    local map_multistep = require("mini.keymap").map_multistep
    map_multistep("i", "<C-y>",   { "pmenu_accept" })
    map_multistep("c", "<C-y>",   { "pmenu_accept" })
    map_multistep("i", "<CR>",    { "minipairs_cr" })
    map_multistep("i", "<BS>",    { "minipairs_bs", "hungry_bs" })
    map_multistep("i", "<Tab>",   { "minisnippets_expand", "minisnippets_next", "jump_after_close", })
    map_multistep("i", "<S-Tab>", { "minisnippets_prev", "jump_before_open", })
    -- stylua: ignore end

    -- General workflow ====================================================================
    require("mini.pick").setup({ mappings = { choose_marked = "<C-q>" } })
    require("mini.visits").setup()
    require("mini.extra").setup()
    require("mini.bufremove").setup()
    require("mini.sessions").setup({ autoread = false, autowrite = true })
    require("mini.git").setup()
    require("mini.diff").setup({ view = { style = "sign" } })
    local MiniMisc = require("mini.misc")
    MiniMisc.setup()
    MiniMisc.setup_restore_cursor()
    -- NOTE: for nix-flakes where direnv is used, this will attempt to load
    -- flake.nix then .envrc as root first incase of monorepo with multiple
    -- flakes, and .envrc files
    MiniMisc.setup_auto_root({ "flake.nix", ".envrc", ".git" })

    -- Mini Clue =======================================================================
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

    -- Appearance ==============================================================
    require("mini.icons").setup()
    require("mini.icons").mock_nvim_web_devicons()
    require("mini.cursorword").setup()
    require("mini.starter").setup()
    require("mini.notify").setup()
    require("mini.statusline").setup()
    require("mini.tabline").setup({ tabpage_section = "none" })

    -- stylua: ignore
    local function apply_custom_highlights()
      local function hl(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false }) or {}
      end

      local bg_main = vim.g.terminal_color_0 or hl("Normal").bg
      local hidden_fg = hl("InclineNormalNC").fg or hl("Comment").fg
      local toolbar_bg = hl("ToolbarLine").bg or hl("StatusLineNC").bg
      vim.api.nvim_set_hl(0, "CurrentWord",                { underline = true })
      vim.api.nvim_set_hl(0, "NormalFloat",                { bg = bg_main })
      vim.api.nvim_set_hl(0, "FloatBorder",                { fg = hl("StatusLineNC").fg, bg = bg_main })
      vim.api.nvim_set_hl(0, "MiniTablineCurrent",         { fg = hl("StatusLine").fg,   bg = hl("NormalNC").bg, bold = true, italic = true })
      vim.api.nvim_set_hl(0, "MiniTablineVisible",         { fg = hl("StatusLineNC").fg, bg = hl("TabLineFill").bg, bold = true })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", { fg = hl("String").fg,       bg = hl("StatusLine").bg, bold = true })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden",  { fg = hl("WarningMsg").fg,   bg = hl("StatusLineNC").bg })
      vim.api.nvim_set_hl(0, "MiniTablineHidden",          { fg = hidden_fg,             bg = toolbar_bg })
      vim.api.nvim_set_hl(0, "MiniTablineFill",            { bg = toolbar_bg })
    end

    apply_custom_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("MiniTablineHighlights", { clear = true }),
      pattern = "*",
      callback = apply_custom_highlights,
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
  end,
}
