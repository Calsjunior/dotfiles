vim.g.mapleader = ","

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Visual settings
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.pumheight = 10 -- Pop up menu height

-- File handling
vim.opt.undofile = true
vim.opt.swapfile = false

-- Behavior settings
vim.opt.hidden = true
vim.opt.backspace = "indent,eol,start" -- Better backspace behavior
vim.opt.clipboard = "unnamedplus"

-- Cursor settings
vim.opt.guicursor =
    "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local map = vim.keymap.set

-- ==========
-- General
-- ==========

-- Editing
map("n", "Y", "y$", { desc = "Yank to end of line" })
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Center screen when jumping
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer mappings
map("n", "<leader>o", "<cmd>update<CR><cmd>source %<CR>")
map("n", "tn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "tp", "<cmd>bprev<CR>", { desc = "Prev Buffer" })

-- Move lines up and down
map("n", "<C-S-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<C-S-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<C-S-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<C-S-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Movement
map("n", "H", "g^", { desc = "Start of line (non-blank)" })
map("n", "L", "g$", { desc = "End of line (non-blank)" })

-- Plugins
map("n", "<leader>wn", "<cmd>noautocmd write<CR>", { desc = "Save without formatting" })
map("n", "<leader>e", "<cmd>Yazi<CR>")
map("n", "<leader>E", "<cmd>Yazi cwd<CR>")

-- ==========
-- Autocmds
-- ==========

local api = vim.api.nvim_create_autocmd

-- Don't auto comment new line
api("BufEnter", { command = [[set formatoptions-=cro]] })

-- Restore terminal clear
api("TermEnter", {
    callback = function(ev)
        vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = ev.buf, nowait = true })
    end,
})

-- Fix terminal escape key override
api("TermOpen", {
    desc = "Manage Terminal Escape Behavior",
    callback = function(event)
        local passthrough_ft = { "lazygit", "yazi", "snacks_terminal" }
        local is_passthrough = vim.tbl_contains(passthrough_ft, vim.bo[event.buf].filetype)

        -- Also check if the buffer name contains specific strings
        local bufname = vim.api.nvim_buf_get_name(event.buf)
        if bufname:match("lazygit") or bufname:match("yazi") then
            is_passthrough = true
        end

        if is_passthrough then
            -- Let <Esc> pass through to the terminal app
            vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = event.buf, nowait = true })
        else
            -- For generic terminals (like :term), let <Esc> enter Normal Mode
            vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = event.buf })
        end
    end,
})

-- Auto activate python env if detected
local function activate_venv()
    local venv_paths = {
        vim.fn.getcwd() .. "/venv",
        vim.fn.getcwd() .. "/.venv",
        vim.fn.getcwd() .. "/env",
    }

    for _, path in ipairs(venv_paths) do
        local python_path = path .. "/bin/python"
        if vim.fn.executable(python_path) == 1 then
            vim.env.VIRTUAL_ENV = path
            vim.env.PATH = path .. "/bin:" .. vim.env.PATH
            vim.notify("🐍 Activated: " .. vim.fn.fnamemodify(path, ":t"))
            return true
        end
    end
    return false
end
api("DirChanged", { callback = activate_venv })

-- Auto indent after closing attribute tags
api("FileType", {
    pattern = { "html", "htmldjango", "xml", "javascriptreact", "typescriptreact" },
    callback = function()
        vim.keymap.set("i", "<CR>", function()
            -- If blink.cmp is active, let it handle <CR>
            local ok, blink_cmp = pcall(require, "blink.cmp")
            if ok and blink_cmp.is_visible and blink_cmp.is_visible() then
                blink_cmp.accept()
                return ""
            end

            local line = vim.api.nvim_get_current_line()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local before = line:sub(1, col)
            local after = line:sub(col + 1)

            -- Check if between tags: >|</
            if before:match(">$") and after:match("^</") then
                return "<CR><Esc>O"
            end

            -- Normal enter
            return "<CR>"
        end, { buffer = true, expr = true, desc = "Smart enter for HTML tags" })
    end,
})

-- Fix python's stupid indents
api("FileType", {
    pattern = { "python" },
    callback = function()
        vim.bo.indentexpr = "v:lua.LazyVim.treesitter.indentexpr()"
        -- vim.bo.indentexpr = "nvim_treesitter#indent()"
        vim.bo.autoindent = true
        vim.bo.smartindent = false
    end,
})
