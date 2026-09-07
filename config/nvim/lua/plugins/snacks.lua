-- stylua: ignore
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker    = { enabled = true },
    scroll    = { enabled = true },
    lazygit   = { enabled = true },
    gitbrowse = { enabled = true },
    gh        = { enabled = true },
    indent    = { enabled = true, scope = { enabled = false } },
    image     = { enabled = true, doc   = { enabled = false, float = true, inline = false, max_width = 60, max_height = 25 } },
  },
}
