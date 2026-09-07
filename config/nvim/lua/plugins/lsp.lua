return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("lua_ls", {
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          })
        end,
        settings = { Lua = {} },
      })

      vim.lsp.config("biome", {
        cmd = { "biome", "lsp-proxy" },
        root_markers = { ".git", "package.json" },
      })

      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css" },
      })

      vim.lsp.config("vtsls", {
        handlers = {
          ["textDocument/publishDiagnostics"] = function() end,
        },
      })

      vim.lsp.config("harper_ls", {
        filetypes = { "markdown", "typst", "text", "gitcommit" },
      })

      -- stylua: ignore
      local servers = {
        "html",     "cssls", "css_variables",
        "vtsls",    "biome", "emmet_language_server",
        "lua_ls",   "nixd",  "clangd",
        "tinymist", "harper_ls",
      }

      for _, lsp in ipairs(servers) do
        vim.lsp.enable(lsp)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    default_format_opts = {
      lsp_format = "fallback",
    },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        -- stylua: ignore start
        c               = { "clang-format" },
        cpp             = { "clang-format" },
        lua             = { "stylua" },
        html            = { "biome-check" },
        css             = { "biome-check" },
        javascript      = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescript      = { "biome-check" },
        typescriptreact = { "biome-check" },
        json            = { "biome-check" },
        jsonc           = { "biome-check" },
        nix             = { "nixfmt" },
      },
      -- stylua: ignore end
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },
}
