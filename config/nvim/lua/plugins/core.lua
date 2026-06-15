return {
  "LazyVim/LazyVim",
  opts = { colorscheme = "habamax" },
  config = function(_, opts)
    require("lazyvim").setup(opts)
    local status, _ = pcall(require, "config.current_theme")
  end,
}
