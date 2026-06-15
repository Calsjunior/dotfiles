return {
  -- Auto-pairing & Tabbing
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  {
    "kawre/neotab.nvim",
    event = "InsertEnter",
    opts = { tabkey = "<Tab>", reverse_key = "<S-Tab>", act_as_tab = true },
  },

  -- Surrounding & Aligning
  { "kylechui/nvim-surround", event = "VeryLazy" },
  {
    "nvim-mini/mini.align",
    keys = {
      { "ga", mode = { "n", "v" } },
      { "gA", mode = { "n", "v" } },
    },
    opts = function()
      local align = require("mini.align")
      return {
        modifiers = {
          ["d"] = function(steps, _)
            table.insert(steps.pre_justify, align.gen_step.filter("n <= 4"))
          end,
        },
      }
    end,
  },

  -- Annotation Generator
  {
    "danymat/neogen",
    opts = {
      enabled = true,
      languages = { cpp = { template = { annotation_convention = "doxygen" } } },
    },
    keys = {
      {
        "<leader>cD",
        function()
          require("neogen").generate()
        end,
        desc = "Generate annotation",
      },
      {
        "<leader>cH",
        function()
          require("neogen").generate({ type = "file" })
        end,
        desc = "Generate File Header",
      },
    },
  },

  -- Autocompletion Engine
  {
    "saghen/blink.cmp",
    dependencies = { "mikavilpas/blink-ripgrep.nvim" },
    opts = {
      completion = {
        accept = { auto_brackets = { enabled = false } },
        menu = { auto_show = true, max_height = 10 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
        transform_items = function(_, items)
          return items
        end,
        min_keyword_length = 1,
        providers = {
          ripgrep = { module = "blink-ripgrep", name = "Ripgrep" },
        },
      },
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
    },
  },
}
