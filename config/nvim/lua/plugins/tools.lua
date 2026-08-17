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

        -- Override the default <leader>n mappings to <leader>j
        keymaps = {
          run_advance = "<leader>jr",
          run_all = "<leader>jR",
          run_above = "<leader>jA",
          run_below = "<leader>jB",

          add_above = "<leader>ja",
          add_below = "<leader>jb",
          delete_cell = "<leader>jd",
          move_up = "<leader>jk",
          move_down = "<leader>jj",
          to_markdown = "<leader>jm",
          to_code = "<leader>jy",
          clear_output = "<leader>jc",
          clear_all = "<leader>jC",

          save_image = "<leader>jI",
          delete_image = "<leader>jD",

          pick_kernel = "<leader>jK",
          start_kernel = "<leader>js",
          stop_kernel = "<leader>jS",
          interrupt_kernel = "<leader>ji",
          restart_kernel = "<leader>jx",
          refresh = "<leader>jL",

          run_stay = false,
          run_advance_alt = false,
          next_cell = false,
          prev_cell = false,
          next_image = false,
          prev_image = false,
        },
      })
    end,
  },
}
