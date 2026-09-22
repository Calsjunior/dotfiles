local add = vim.pack.add
local now, now_if_args, later, on_event = Config.now, Config.now_if_args, Config.later, Config.on_event

-- Language Server Configurations =============================================
now_if_args(function()
  add({ "https://github.com/neovim/nvim-lspconfig" })

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

  vim.lsp.config("emmet_language_server", { filetypes = { "html", "css" } })

  vim.lsp.config("vtsls", { handlers = { ["textDocument/publishDiagnostics"] = function() end } })

  vim.lsp.config("harper_ls", { filetypes = { "markdown", "typst", "text", "gitcommit" } })

  vim.lsp.enable({
    "html",
    "cssls",
    "css_variables",
    "vtsls",
    "biome",
    "emmet_language_server",
    "lua_ls",
    "nixd",
    "clangd",
    "tinymist",
    "harper_ls",
  })
end)

-- Formatting =================================================================
later(function()
  add({ "https://github.com/stevearc/conform.nvim" })

  require("conform").setup({
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      -- stylua: ignore start
      c               = { 'clang-format' },
      cpp             = { 'clang-format' },
      lua             = { 'stylua' },
      html            = { 'biome-check' },
      css             = { 'biome-check' },
      javascript      = { 'biome-check' },
      javascriptreact = { 'biome-check' },
      typescript      = { 'biome-check' },
      typescriptreact = { 'biome-check' },
      json            = { 'biome-check' },
      jsonc           = { 'biome-check' },
      nix             = { 'nixfmt' },
      -- stylua: ignore end
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_fallback = true,
    },
  })
end)

-- Terminal & Multiplexer =====================================================
later(function()
  add({ "https://github.com/mrjones2014/smart-splits.nvim" })
  require("smart-splits").setup({
    ignored_filetypes = { "NvimTree" },
    multiplexer_integration = "kitty",
  })
end)

on_event("User~KittyScrollbackLaunch", function()
  add({ "https://github.com/mikesmithgh/kitty-scrollback.nvim" })
  require("kitty-scrollback").setup({
    paste_window = { yank_register_enabled = false, hide_footer = true },
  })
end)

-- Explorer ===================================================================
later(function()
  add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/mikavilpas/yazi.nvim",
  })
  require("yazi").setup({ open_for_directories = true })
end)

-- For nix-flakes with direnv =================================================
now(function()
  add({ "https://github.com/NotAShelf/direnv.nvim" })
  require("direnv").setup({ autoload_direnv = true })
end)

-- Snippet Collection =========================================================
later(function()
  add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

-- Command Line ===============================================================
later(function()
  add({ "https://github.com/rachartier/tiny-cmdline.nvim" })
  vim.o.cmdheight = 0
  require("tiny-cmdline").setup({
    width = { value = "50%" },
    position = { y = "10%" },
    title = { enabled = true, pos = "center" },
  })
end)

-- Colorscheme ================================================================
now(function()
  add({ "https://github.com/sainnhe/gruvbox-material" })
  vim.g.gruvbox_material_background = "medium"
  vim.cmd("colorscheme gruvbox-material")
end)
