local api = vim.api

-- Don't auto comment new line
api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- Restore terminal clear
vim.api.nvim_create_autocmd("TermEnter", {
    callback = function(ev)
        vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = ev.buf, nowait = true })
    end,
})

-- Fix terminal escape key override
vim.api.nvim_create_autocmd("TermOpen", {
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
vim.api.nvim_create_autocmd("DirChanged", { callback = activate_venv })

-- Auto indent after closing attribute tags
vim.api.nvim_create_autocmd("FileType", {
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
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function()
        vim.bo.indentexpr = "v:lua.LazyVim.treesitter.indentexpr()"
        -- vim.bo.indentexpr = "nvim_treesitter#indent()"
        vim.bo.autoindent = true
        vim.bo.smartindent = false
    end,
})
