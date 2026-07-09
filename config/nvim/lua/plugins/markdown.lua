return {
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    opts = {
      preview = {
        enable = false,
      },
    },
    keys = {
      { "<leader>mi", "<cmd>Markview toggle<cr>", desc = "Toggle Markview (Inline)" },
      { "<leader>mv", "<cmd>Markview splitToggle<cr>", desc = "Toggle Markview (Split)" },
    },
  },
  {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {},
  },
}
