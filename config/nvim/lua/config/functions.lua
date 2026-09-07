local M = {}

local augroups = {}
function M.autocmd(event, opts)
  local final_opts = vim.tbl_extend("force", {}, opts)

  if type(opts.group) == "string" then
    if not augroups[opts.group] then
      augroups[opts.group] = vim.api.nvim_create_augroup(opts.group, { clear = true })
    end
    final_opts.group = augroups[opts.group]
  end

  vim.api.nvim_create_autocmd(event, final_opts)
end

-- Incremental Selection (see keymaps.lua) ====================================
function M.ts_or_lsp(ts_dir, lsp_mult)
  return function()
    if not vim.treesitter.get_parser(nil, nil, { error = false }) then
      return vim.lsp.buf.selection_range(lsp_mult * vim.v.count1)
    end

    vim.treesitter.select(ts_dir, vim.v.count1)
  end
end

-- Buffer operations ==========================================================
local function listed_buffers()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

function M.close_other_buffers()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(listed_buffers()) do
    if buf ~= cur then
      MiniBufremove.delete(buf, false)
    end
  end
end

function M.close_buffers_right()
  local cur = vim.api.nvim_get_current_buf()
  local found = false
  for _, buf in ipairs(listed_buffers()) do
    if found then
      MiniBufremove.delete(buf, false)
    elseif buf == cur then
      found = true
    end
  end
end

function M.close_buffers_left()
  for _, buf in ipairs(listed_buffers()) do
    if buf == vim.api.nvim_get_current_buf() then
      break
    end
    MiniBufremove.delete(buf, false)
  end
end

-- Compile/run current file ===================================================
function M.compile_and_run(compiler, ext)
  local raw_dir = vim.fn.expand("%:p:h")
  local dir = vim.fn.shellescape(raw_dir)
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  local file_no_ext = vim.fn.shellescape(vim.fn.expand("%:p:r"))

  if vim.fn.filereadable(raw_dir .. "/Makefile") == 1 then
    return "cd " .. dir .. " && make"
  end
  local choice = vim.fn.confirm("Compile Mode:", "&1. Just this file\n&2. All *." .. ext .. " files", 1)
  if choice == 1 then
    return "cd " .. dir .. " && " .. compiler .. " " .. file .. " -o " .. file_no_ext .. " && " .. file_no_ext
  elseif choice == 2 then
    return "cd " .. dir .. " && " .. compiler .. " *." .. ext .. " -o " .. file_no_ext .. " && " .. file_no_ext
  end
  return nil
end

function M.run_current_file()
  vim.cmd("silent! w")
  local ft = vim.bo.filetype

  local runners = {
    javascript = "node " .. vim.fn.shellescape(vim.fn.expand("%:p")),
    python = "python3 " .. vim.fn.shellescape(vim.fn.expand("%:p")),
    sh = "bash " .. vim.fn.shellescape(vim.fn.expand("%:p")),
    c = function()
      return M.compile_and_run("gcc", "c")
    end,
    cpp = function()
      return M.compile_and_run("g++", "cpp")
    end,
  }

  local runner = runners[ft]
  if not runner then
    vim.notify("No run command configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local cmd = type(runner) == "function" and runner() or runner
  if not cmd then
    return
  end

  vim.cmd("botright 15new")
  vim.fn.jobstart(cmd, { term = true })
  vim.cmd("startinsert")
end

-- Snippet insertion ==========================================================
function M.insert_snippet()
  local base_dir = "~/dev"
  local ft_map = {
    html = "web/snippets/html",
    css = "web/snippets/css",
    javascript = "web/snippets/js",
    c = "c/snippets",
    cpp = "cpp/snippets",
    typst = "typst/snippets",
  }
  local folder = ft_map[vim.bo.filetype]
  if not folder then
    vim.notify("No snippet folder for: " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end
  local snippet_dir = vim.fn.expand(base_dir .. "/" .. folder)
  if vim.fn.isdirectory(snippet_dir) == 0 then
    vim.notify("Snippet directory not found: " .. snippet_dir, vim.log.levels.ERROR)
    return
  end
  Snacks.picker.files({
    cwd = snippet_dir,
    title = "Insert Snippet [" .. vim.bo.filetype .. "]",
    confirm = function(picker, item)
      picker:close()
      if item then
        local full_path = snippet_dir .. "/" .. item.file
        local lines = vim.fn.readfile(full_path)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local is_empty = vim.api.nvim_get_current_line():match("^%s*$") ~= nil
        vim.api.nvim_buf_set_lines(0, row - 1, is_empty and row or (row - 1), false, lines)
      end
    end,
  })
end

-- Project-local config execution =============================================
function M.source_project_config()
  local local_config = vim.fn.getcwd() .. "/.nvim.lua"
  if vim.fn.filereadable(local_config) == 0 then
    vim.notify("No .nvim.lua found in project root", vim.log.levels.WARN)
    return
  end

  local content = vim.secure.read(local_config)
  if not content then
    vim.notify("Execution blocked: .nvim.lua is not trusted.", vim.log.levels.WARN)
    return
  end

  local chunk, err = load(content, "@" .. local_config)
  if not chunk then
    vim.notify("Syntax error in " .. local_config .. ": " .. err, vim.log.levels.ERROR)
    return
  end

  chunk()
  vim.notify("Sourced: " .. local_config, vim.log.levels.INFO)
  vim.schedule(function()
    if vim.bo.filetype ~= "" then
      vim.cmd("doautocmd FileType " .. vim.bo.filetype)
    end
  end)
end

-- Kitty IPC ==================================================================
function M.kitty_launch(args, post_cmd)
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  vim.fn.system(string.format("kitty @ launch %s --cwd=%s", args, vim.fn.shellescape(dir)))
  if post_cmd then
    vim.fn.system(post_cmd)
  end
end

return M
