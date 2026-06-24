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
        biome = {
          cmd = { "biome", "lsp-proxy" },
          root_dir = function(bufnr, on_dir)
            local found = vim.fs.find({ "biome.json", "biome.jsonc" }, {
              path = vim.api.nvim_buf_get_name(bufnr),
              upward = true,
            })[1]
            on_dir(found and vim.fs.dirname(found) or vim.fn.expand("~"))
          end,
        },
        emmet_language_server = { filetypes = { "html", "css" } },
        vtsls = {
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
