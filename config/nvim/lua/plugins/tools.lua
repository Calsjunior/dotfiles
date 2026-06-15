return {
  -- Environment Management
  {
    "NotAShelf/direnv.nvim",
    opts = { autoload_direnv = true },
  },

  -- Typst
  {
    "chomosuke/typst-preview.nvim",
    version = "1.*",
    ft = "typst",
    opts = {},
  },

  -- Jupyter
  {
    "sheng-tse/jupynvim",
    ft = { "python" },
    build = function()
      local core = vim.fn.stdpath("data") .. "/lazy/jupynvim/core"
      vim.fn.system({
        "cargo",
        "build",
        "--release",
        "--manifest-path",
        core .. "/Cargo.toml",
      })
    end,
    config = function()
      require("jupynvim").setup({
        log_level = "info",
        image_renderer = "kitty",
      })
    end,
  },
}
