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
}
