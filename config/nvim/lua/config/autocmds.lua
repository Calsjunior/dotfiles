-- Don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- Restore terminal clear
vim.api.nvim_create_autocmd("TermEnter", {
  callback = function(ev)
    vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = ev.buf, nowait = true })
  end,
})

-- Disable wrapping
vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = true })

-- When opening a project via `nvim .`, yazi intercepts the directory and opens it.
-- However, mksession (used by persistence.nvim) saves the directory as a buffer
-- entry in the session file. On next project load, the directory buffer gets
-- restored as an empty unlisted buffer.
--
-- Additionally, mksession saves all buffers that were added during the session,
-- including ones deleted with :bd. These ghost buffers show up in bufferline
-- on next project load even though they were removed.
--
-- This autocmd fires after persistence writes the session file and rewrites it,
-- stripping any `badd` or `argadd` lines that:
--   1. Point to directories (yazi directory buffer issue)
--   2. Point to buffers that exist but are not visible in any window (ghost buffers)
vim.api.nvim_create_autocmd("User", {
  pattern = "PersistenceSavePost",
  callback = function()
    local session_file = require("persistence").current()
    if not session_file or vim.fn.filereadable(session_file) == 0 then
      return
    end
    local lines = vim.fn.readfile(session_file)
    local filtered = vim.tbl_filter(function(line)
      -- Strip directory buffers
      if line:match("^badd") or line:match("^%$argadd") or line:match("^argadd") then
        local path = line:match("%s(.+)$")
        if path then
          local expanded = vim.fn.expand(path)
          if vim.fn.isdirectory(expanded) == 1 then
            return false
          end
          -- Strip buffers that are not visible in any window
          local bufnr = vim.fn.bufnr(expanded)
          if bufnr ~= -1 and #vim.fn.win_findbuf(bufnr) == 0 then
            return false
          end
        end
      end
      return true
    end, lines)
    vim.fn.writefile(filtered, session_file)
  end,
})
