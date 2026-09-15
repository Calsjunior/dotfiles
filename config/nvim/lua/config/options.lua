-- stylua: ignore start
-- General ====================================================================
vim.g.mapleader      = ","
vim.g.maplocalleader = " "

vim.o.exrc      = true          -- Enable project-specific .nvim.lua files
vim.o.undofile  = true          -- Enable persistent undo across sessions
vim.o.swapfile  = false         -- Disable swap files
vim.o.hidden    = true          -- Keep unsaved buffers in the background
vim.o.clipboard = "unnamedplus" -- Sync with system clipboard

-- UI =========================================================================
vim.o.number          = true          -- Show absolute line numbers
vim.o.relativenumber  = true          -- Show relative line numbers
vim.o.cursorline      = true          -- Highlight current line
vim.o.wrap            = false         -- Disable line wrapping
vim.o.scrolloff       = 99            -- Keep cursor vertically centered
vim.opt.scrolloffpad = 1              -- Padding for scrolloff EOF
vim.o.sidescrolloff   = 8             -- Keep cursor 8 columns away from horizontal edges
vim.o.signcolumn      = "yes"         -- Always show signcolumn to prevent flicker
vim.o.ruler           = false         -- Don't show cursor coordinates
vim.o.showmode        = false         -- Hide "-- INSERT --" since statusline handles it
vim.o.showcmdloc      = "statusline"
vim.o.laststatus      = 3             -- Enable only one status line for entire neovim session
vim.o.pumheight       = 10            -- Max items in popup menu
vim.o.winborder       = "rounded"     -- Rounded borders for floating windows
vim.o.fillchars       = "eob: "       -- Hide `~` on empty lines
vim.o.splitbelow      = true          -- Horizontal splits will open below
vim.o.splitright      = true          -- Vertical splits will open to the right
vim.o.splitkeep       = "screen"      -- Keep text on the same screen line when splitting
vim.o.breakindent     = true          -- Indent wrapped lines to match line start
vim.o.linebreak       = true          -- Wrap long lines at a word boundary, not in the middle of a word
vim.o.pummaxwidth     = 100           -- Limit maximum width of popup menu
vim.o.completetimeout = 100
vim.o.pumborder       = 'rounded'     -- Use border in built-in completion menu
require('vim._core.ui2').enable({ enable = true })

-- Show trailing spaces and tabs
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

-- Cursor shape & blinking
vim.o.guicursor = "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor"

-- Editing ====================================================================
vim.o.autoindent  = true                     -- Copy indent from current line when starting a new one
vim.o.expandtab   = true                     -- Use spaces instead of tabs
vim.o.tabstop     = 2                        -- Number of spaces tabs count for
vim.o.shiftwidth  = 2                        -- Size of an indent
vim.o.softtabstop = 2
vim.o.smartindent = true                     -- Insert indents automatically
vim.o.backspace   = "indent,eol,start"       -- Allow backspacing over everything
vim.o.virtualedit = "block"                  -- Allow going past the end of line in visual block mode
vim.o.completeopt = "fuzzy,menuone,noinsert" -- Auto select first match in completion menu
vim.o.wildmode    = "noinsert:full"          -- Auto select first match in commandline menu

-- Pattern for a start of 'numbered' list (used in `gw`). This reads as
-- "Start of list item is: at least one special character (digit, -, +, *)
-- possibly followed by punctuation (. or `)`) followed by at least one space".
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- Search =====================================================================
vim.o.ignorecase = true -- Ignore case when searching
vim.o.smartcase  = true -- Override ignorecase if search contains capitals
vim.o.hlsearch   = true -- Highlight all search matches
vim.o.incsearch  = true -- Show matches dynamically as you type

if vim.fn.has("nvim-0.13") == 1 then
  vim.o.updatetime = 200        -- Faster completion and CursorHold events
end

-- Autocommands ===============================================================
local autocmd = require("config.functions").autocmd

-- Enable treesitters installed with home manager
local hm_pack = vim.fn.expand("~/.local/share/nvim/site/pack/hm/start/")
vim.opt.runtimepath:append(hm_pack .. "nvim-treesitter")
vim.opt.runtimepath:append(hm_pack .. "nvim-treesitter-grammars")
autocmd("FileType", { pattern = "*", callback = function(args) pcall(vim.treesitter.start, args.buf) end })

-- Highlight on yank
autocmd("TextYankPost", { group = "highlight_yank", callback = function() vim.hl.hl_op() end })

-- Don't auto comment new line
autocmd("Filetype", { group = "format_options", command = "set formatoptions-=cro" })

-- Close filetypes with 'q'
autocmd("FileType", {
  group = "close_with_q", pattern = { "checkhealth", "help", "lspinfo", "qf", "git", "mininotify-history" },
  callback = function(e)
    vim.bo[e.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        if e.match == "mininotify-history" then return require("mini.bufremove").wipeout(e.buf, true) end
        pcall(function() vim.cmd("close") end)
        pcall(vim.api.nvim_buf_delete, e.buf, { force = true })
      end, { buffer = e.buf, silent = true, desc = "Quit buffer" })
    end)
  end,
})

-- Open binary files in external program
autocmd("BufReadCmd", {
  group = "open_external_files",
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg", "*.pdf" },
  callback = function(e)
    vim.ui.open(e.match)
    vim.schedule(function()
      require("mini.bufremove").wipeout(e.buf, true)
    end)
  end,
})

autocmd("ColorScheme", {
  group = "global_ui_overrides",
  pattern = "*",
  callback = function()
    local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    local get = function(name) return vim.api.nvim_get_hl(0, { name = name }) or {} end

    local bg_main       = get("Normal").bg
    local fg_main       = get("Normal").fg
    local bg_cursorline = get("CursorLine").bg
    local bg_visual     = get("Visual").bg
    local fg_string     = get("String").fg
    local fg_comment    = get("Comment").fg
    local bg_toolbar    = get("StatusLineNC").bg

    hi("Pmenu",         { bg = bg_main,       fg = fg_main })
    hi("PmenuSel",      { bg = bg_cursorline, bold = true })
    hi("PmenuBorder",   { fg = get("StatusLineNC").fg })
    hi("PmenuSbar",     { bg = bg_main })
    hi("PmenuThumb",    { bg = bg_visual })
    hi("PmenuExtra",    { bg = bg_main,       fg = fg_comment })
    hi("PmenuExtraSel", { bg = bg_cursorline, fg = fg_comment, bold = true })
    hi("PmenuKind",     { bg = bg_main,       fg = fg_comment })
    hi("PmenuKindSel",  { bg = bg_cursorline, fg = fg_comment, bold = true })

    hi("MiniTablineCurrent",         { fg = get("StatusLine").fg,   bg = get("NormalNC").bg, bold = true, italic = true })
    hi("MiniTablineVisible",         { fg = get("StatusLineNC").fg, bg = get("TabLineFill").bg, bold = true })
    hi("MiniTablineModifiedCurrent", { fg = fg_string,              bg = get("StatusLine").bg, bold = true })
    hi("MiniTablineModifiedHidden",  { fg = get("WarningMsg").fg,   bg = bg_toolbar })
    hi("MiniTablineHidden",          { fg = fg_comment,             bg = bg_toolbar })
    hi("MiniTablineFill",            { bg = bg_toolbar })

    hi("NormalFloat", { bg = bg_main })
    hi("FloatBorder", { fg = get("StatusLineNC").fg, bg = bg_main })
    hi("CurrentWord", { underline = true })
  end,
})

-- Diagnostics ================================================================
local severity = vim.diagnostic.severity
vim.diagnostic.config({
  signs = { priority = 9999, severity = { min = severity.WARN, max = severity.ERROR } },
  underline = { severity = { min = severity.HINT, max = severity.ERROR } },
  virtual_lines = false,
  virtual_text = {
    current_line = true, severity = { min = severity.ERROR, max = severity.ERROR },
  },
  update_in_insert = false,
})

-- stylua: ignore end
