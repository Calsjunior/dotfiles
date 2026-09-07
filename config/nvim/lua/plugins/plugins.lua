return {
  -- Terminal Workflow ========================================================
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    -- stylua: ignore start
    opts = {
      ignored_filetypes       = { "NvimTree" },
      multiplexer_integration = "kitty",
    },
    -- stylua: ignore end
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    opts = { paste_window = { yank_register_enabled = false, hide_footer = true } },
  },

  -- Explorer =================================================================
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    opts = {
      open_for_directories = true,
      open_file_function = function(chosen_file)
        local ext = chosen_file:match("^.+%.(.+)$")
        -- stylua: ignore
        local external_exts = {
          png  = true, jpg = true, jpeg = true, gif = true,
          webp = true, svg = true, pdf  = true,
        }
        if ext and external_exts[ext:lower()] then
          vim.fn.jobstart({ "xdg-open", chosen_file }, { detach = true })
        else
          vim.cmd.edit(vim.fn.fnameescape(chosen_file))
        end
      end,
    },
  },

  -- For nix-flakes with direnv ===============================================
  { "actionshrimp/direnv.nvim", opts = {} },

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
}
