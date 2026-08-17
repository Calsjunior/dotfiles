return {
  -- Environment Management
  {
    "NotAShelf/direnv.nvim",
    opts = { autoload_direnv = true },
  },

  -- Jupyter
  {
    "sheng-tse/jupynvim",
    event = "BufReadCmd *.ipynb",
    build = function()
      local core = vim.fn.stdpath("data") .. "/lazy/jupynvim/core"
      vim.fn.system({
        "nix",
        "shell",
        "nixpkgs#cargo",
        "nixpkgs#rustc",
        "-c",
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
        core_path = vim.fn.stdpath("data") .. "/lazy/jupynvim/core/target/release/jupynvim-core",
      })
    end,
  },
}
