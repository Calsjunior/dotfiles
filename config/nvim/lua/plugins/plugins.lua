return {
  -- stylua: ignore start
  -- Terminal Workflow ========================================================
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      ignored_filetypes       = { "NvimTree" },
      multiplexer_integration = "kitty",
    },
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true, lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    opts = { paste_window = { yank_register_enabled = false, hide_footer = true } },
  },

  -- Snacks for git enhancement ===============================================
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      picker    = { enabled = true },
      scroll    = { enabled = true },
      lazygit   = { enabled = true },
      gh        = { enabled = true },
      indent    = { enabled = true, scope = { enabled = false } },
      image     = { enabled = true, doc   = { enabled = false, float = true, inline = false, max_width = 60, max_height = 25 } },
    },
  },

  -- Explorer =================================================================
  { "mikavilpas/yazi.nvim", event = "VeryLazy", opts = { open_for_directories = true } },

  -- For nix-flakes with direnv ===============================================
  { "NotAShelf/direnv.nvim", opts = { autoload_direnv = true } },

  -- Command line appearance ==================================================
  {
    "rachartier/tiny-cmdline.nvim",
    init = function()
      vim.o.cmdheight = 0
    end,
    config = function()
      -- stylua: ignore
      require("tiny-cmdline").setup({
        width    = { value   = "50%" },
        position = { y       = "10%" },
        title    = { enabled = true, pos = "center" },
      })
    end,
  },

  -- Colorscheme ==============================================================
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "medium"
      vim.cmd("colorscheme gruvbox-material")
    end,
  },
  -- stylua: ignore end
}
