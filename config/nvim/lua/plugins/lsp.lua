return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      folds = { enabled = false },
      servers = {
        html = {},
        cssls = {},
        nixd = {},
        clangd = {},
        biome = {},
        emmet_language_server = { filetypes = { "html", "css" } },
        ts_ls = {
          handlers = { ["textDocument/publishDiagnostics"] = function() end },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_format" },
        lua = { "stylua" },
        html = { "biome-check" },
        css = { "biome-check" },
        javascript = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescript = { "biome-check" },
        typescriptreact = { "biome-check" },
        json = { "biome-check" },
        jsonc = { "biome-check" },
        sh = { "shfmt" },
        nix = { "nixfmt" },
      },
    },
  },
}
