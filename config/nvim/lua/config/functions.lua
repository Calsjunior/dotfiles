local M = {}

-- For easy autocmds creation =================================================
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
  -- stylua: ignore start
  local map = {
    html = "web/snippets/html", css = "web/snippets/css", javascript = "web/snippets/js",
    c    = "c/snippets",        cpp = "cpp/snippets",     typst      = "typst/snippets"
  }

  if not map[vim.bo.filetype] then return vim.notify("No snippets for: " .. vim.bo.filetype, 3) end
  local dir = vim.fn.expand(base_dir .. "/" .. map[vim.bo.filetype])
  if vim.fn.isdirectory(dir) == 0 then return vim.notify("Dir not found: " .. dir, 4) end

  local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
  require("mini.pick").builtin.files(nil, {
    source = {
      cwd = dir, name = "Snippets",
      choose = function(item)
        if not item then return end
        local row = vim.api.nvim_win_get_cursor(win)[1]
        local empty = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]:match("^%s*$")
        vim.api.nvim_buf_set_lines(buf, row - 1, empty and row or (row - 1), false, vim.fn.readfile(dir .. "/" .. item))
      end
    }
  })

  -- stylua: ignore end
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

-- Git ========================================================================
function M.gitbrowse(is_visual)
  local function git(args)
    local res = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
    return res.code == 0 and vim.trim(res.stdout) or nil
  end

  local remote = git({ "config", "--get", "remote.origin.url" })
  if not remote then
    return vim.notify("No git remote", 3)
  end

  local ref = git({ "rev-parse", "--verify", "@{u}" }) and git({ "rev-parse", "--abbrev-ref", "HEAD" })
    or git({ "rev-parse", "HEAD" })

  local repo = remote:gsub("^git@", ""):gsub("^https?://", ""):gsub("%.git$", ""):gsub(":", "/")
  local file = git({ "ls-files", "--full-name", vim.api.nvim_buf_get_name(0) })
  local url = "https://" .. repo

  if file and file ~= "" then
    local l1, l2 = vim.fn.line("."), is_visual and vim.fn.line("v") or vim.fn.line(".")
    local start_l, end_l = math.min(l1, l2), math.max(l1, l2)
    local is_gl = repo:match("gitlab")

    local blob = is_gl and "/-/blob/" or "/blob/"
    local lines = (start_l == end_l) and ("#L" .. start_l)
      or string.format(is_gl and "#L%d-%d" or "#L%d-L%d", start_l, end_l)

    url = url .. blob .. ref .. "/" .. file .. lines
  end

  vim.ui.open(url)
  vim.notify("Opened: " .. url)
  if is_visual then
    vim.api.nvim_input("<Esc>")
  end
end

return M
