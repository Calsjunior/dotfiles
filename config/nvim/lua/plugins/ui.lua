return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
  },
  {
    "Aasim-A/scrollEOF.nvim",
    event = { "CursorMoved", "WinScrolled" },
    opts = {},
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      css = { css = true },
    },
  },
}
