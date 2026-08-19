-- FIXME: Remove flash's monkey patch once fixed, issue: https://github.com/folke/flash.nvim/issues/495
local function patch_flash_searchstate()
  local Hacks = require("flash.hacks") -- triggers flash's own ffi.cdef of the old symbols
  local ffi = require("ffi")

  -- Old standalone symbol still resolvable? then leave flash's own hacks alone.
  if pcall(function()
    return ffi.C.search_match_lines
  end) then
    return
  end

  -- New: SearchState struct (src/nvim/search_defs.h), exported global `Search`.
  pcall(
    ffi.cdef,
    [[
      typedef struct {
        bool    hl_match;
        int32_t match_lines;
        int     match_endcol;
        int32_t first_line;
        int32_t last_line;
        bool    no_smartcase;
        int     cmdlen;
        bool    no_hlsearch;
      } SearchState;
      SearchState Search;
    ]]
  )

  -- Struct not resolvable? leave flash as-is (don't make it worse).
  if not pcall(function()
    return ffi.C.Search.match_lines
  end) then
    return
  end

  local C = ffi.C
  local Pos = require("flash.search.pos")
  local incsearch_state = {}

  function Hacks.get_end_pos(from)
    local ret = Pos({
      from[1] + C.Search.match_lines,
      math.max(0, C.Search.match_endcol - 1),
    })
    local line = vim.api.nvim_buf_get_lines(0, ret[1] - 1, ret[1], false)[1]
    local char_idx = vim.fn.charidx(line, ret[2])
    ret[2] = vim.fn.byteidx(line, char_idx)
    return ret
  end

  function Hacks.save_incsearch_state()
    incsearch_state = {
      match_endcol = C.Search.match_endcol,
      match_lines = C.Search.match_lines,
    }
  end

  function Hacks.restore_incsearch_state()
    C.Search.match_endcol = incsearch_state.match_endcol
    C.Search.match_lines = incsearch_state.match_lines
  end
end

return {
  -- Sudo operations
  {
    "lambdalisue/suda.vim",
    init = function()
      vim.g.suda_smart_edit = 1
    end,
    cmd = { "SudaRead", "SudaWrite" },
  },

  -- File Explorer
  {
    "mikavilpas/yazi.nvim",
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
    event = "VeryLazy",
    opts = { open_for_directories = true },
  },

  -- Movement
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    init = patch_flash_searchstate(),
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      label = { distance = true },
      modes = { treesitter = { label = { rainbow = { enabled = true, shade = 7 } } } },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = { max_length = 2 },
            jump = { autojump = true },
            label = { min_pattern_length = 2 },
          })
        end,
        desc = "Flash (Smart Filtering)",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  -- Window Management
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      ignored_buftypes = { "nofile", "quickfix", "prompt" },
      ignored_filetypes = { "NvimTree" },
      multiplexer_integration = "kitty",
    },
    keys = {
      {
        "<A-h>",
        function()
          require("smart-splits").resize_left()
        end,
        desc = "Resize split left",
      },
      {
        "<A-j>",
        function()
          require("smart-splits").resize_down()
        end,
        desc = "Resize split down",
      },
      {
        "<A-k>",
        function()
          require("smart-splits").resize_up()
        end,
        desc = "Resize split up",
      },
      {
        "<A-l>",
        function()
          require("smart-splits").resize_right()
        end,
        desc = "Resize split right",
      },
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Move to left split",
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Move to below split",
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Move to above split",
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Move to right split",
      },
    },
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    opts = {
      {
        paste_window = {
          yank_register_enabled = false,
          hide_footer = true,
        },
      },
    },
  },
}
