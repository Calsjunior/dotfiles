-- Don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

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

-- Fix python's stupid indents
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function()
        -- vim.bo.indentexpr = "v:lua.LazyVim.treesitter.indentexpr()"
        vim.bo.indentexpr = "nvim_treesitter#indent()"
        vim.bo.autoindent = true
        vim.bo.smartindent = false
    end,
})

-- Markdown configs
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(e)
        -- Enable snacks image
        local ok, image_doc = pcall(require, "snacks.image.doc")
        if ok then
            image_doc.attach(e.buf)
        end

        vim.opt_local.spell = true
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
})

-- Disable wrapping
vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = true })

-- When opening a project via `nvim .`, yazi intercepts the directory and opens it.
-- However, mksession (used by persistence.nvim) saves the directory as a buffer
-- entry in the session file. On next project load, the directory buffer gets
-- restored as an empty unlisted buffer. This autocmd fires after persistence writes
-- the session file and rewrites it, stripping any `badd` or `argadd` lines that
-- point to directories.
vim.api.nvim_create_autocmd("User", {
    pattern = "PersistenceSavePost",
    callback = function()
        local session_file = require("persistence").current()
        if not session_file or vim.fn.filereadable(session_file) == 0 then
            return
        end
        local lines = vim.fn.readfile(session_file)
        local filtered = vim.tbl_filter(function(line)
            if line:match("^badd") or line:match("^%$argadd") or line:match("^argadd") then
                local path = line:match("%s(.+)$")
                if path and vim.fn.isdirectory(vim.fn.expand(path)) == 1 then
                    return false
                end
            end
            return true
        end, lines)
        vim.fn.writefile(filtered, session_file)
    end,
})
