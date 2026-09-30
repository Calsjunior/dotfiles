-- stylua: ignore start
-- Define custom autocommand group
local gr = vim.api.nvim_create_augroup("custom-config", {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- Incremental Selection (see keymaps.lua) ====================================
function Config.ts_or_lsp(ts_dir, lsp_mult)
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

local function close_buffers(should_close)
  local cur = vim.api.nvim_get_current_buf()
  local past_cur = false
  for _, buf in ipairs(listed_buffers()) do
    if buf == cur then past_cur = true
    elseif should_close(past_cur) then MiniBufremove.delete(buf, false) end
  end
end

function Config.close_other_buffers() close_buffers(function() return true end) end
function Config.close_buffers_right() close_buffers(function(past) return past end) end
function Config.close_buffers_left()  close_buffers(function(past) return not past end) end

-- Project-local config execution =============================================
function Config.source_project_config()
  local local_config = vim.fn.getcwd() .. "/.nvim.lua"
  if vim.fn.filereadable(local_config) == 0 then
    return vim.notify("No .nvim.lua found in project root", vim.log.levels.WARN)
  end

  local content = vim.secure.read(local_config)
  if not content then
    return vim.notify("Execution blocked: .nvim.lua is not trusted.", vim.log.levels.WARN)
  end

  local chunk, err = load(content, "@" .. local_config)
  if not chunk then
    return vim.notify("Syntax error in " .. local_config .. ": " .. err, vim.log.levels.ERROR)
  end

  chunk()
  vim.notify("Sourced: " .. local_config, vim.log.levels.INFO)
  vim.schedule(function()
    if vim.bo.filetype ~= "" then vim.api.nvim_exec_autocmds("FileType", {}) end
  end)
end

-- Kitty IPC ==================================================================
function Config.kitty_launch(args, post_cmd)
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then dir = vim.fn.getcwd() end

  vim.system(vim.list_extend({ "kitty", "@", "launch", "--cwd=" .. dir }, args)):wait()
  if post_cmd then vim.system(post_cmd):wait() end
end

-- Helper to create floating terminals ========================================
local function float_config(opts)
  local width = math.floor(vim.o.columns * (opts.width_pct or 0.85))
  local height = math.floor(vim.o.lines * (opts.height_pct or 0.85))
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
  }
end

local function float_term(cmd, opts)
  opts = opts or {}
  local buf = vim.api.nvim_create_buf(false, true)
  local win_cfg = vim.tbl_extend("force", float_config(opts), {
    style = "minimal",
    border = "rounded",
    title = opts.title and (" " .. opts.title .. " ") or nil,
    title_pos = opts.title and "center" or nil,
  })
  local win = vim.api.nvim_open_win(buf, true, win_cfg)

  local resize_au = vim.api.nvim_create_autocmd("VimResized", {
    group = gr,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, float_config(opts))
      end
    end,
  })

  local function close()
    pcall(vim.api.nvim_del_autocmd, resize_au)
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end

  vim.fn.jobstart(cmd, {
    term = true,
    env = opts.env,
    on_exit = function(_, code)
      close()
      if opts.on_exit then opts.on_exit(code) end
    end,
  })

  vim.cmd("startinsert")
  return { win = win, buf = buf, close = close }
end

-- Git ========================================================================
function Config.gitbrowse(is_visual)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local function git(args)
    local res = vim.system(vim.list_extend({ "git" }, args), { text = true, cwd = dir }):wait()
    return res.code == 0 and vim.trim(res.stdout) or nil
  end

  local remote = git({ "config", "--get", "remote.origin.url" })
  if not remote then return vim.notify("No git remote", vim.log.levels.WARN) end

  local ref = git({ "rev-parse", "--verify", "@{u}" }) and git({ "rev-parse", "--abbrev-ref", "HEAD" })
    or git({ "rev-parse", "HEAD" })

  local repo = remote:gsub("^git@", ""):gsub("^https?://", ""):gsub("%.git$", ""):gsub(":", "/")
  local file = git({ "ls-files", "--full-name", vim.api.nvim_buf_get_name(0) })
  local url = "https://" .. repo

  if file and file ~= "" then
    local l1, l2 = vim.fn.line("."), vim.fn.line("v")
    local start_l, end_l = math.min(l1, l2), math.max(l1, l2)
    local is_gl = repo:match("gitlab")

    local blob = is_gl and "/-/blob/" or "/blob/"
    local lines = (start_l == end_l) and ("#L" .. start_l)
      or string.format(is_gl and "#L%d-%d" or "#L%d-L%d", start_l, end_l)

    url = url .. blob .. ref .. "/" .. file .. lines
  end

  vim.ui.open(url)
  vim.notify("Opened: " .. url)
  if is_visual then vim.api.nvim_input("<Esc>") end
end

function Config.lazygit()
  local function hex(hl_name, attr)
    local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
    return hl[attr] and string.format("#%06x", hl[attr]) or "default"
  end
  local theme_yaml = string.format([[
os:
  editPreset: 'nvim-remote'
  edit: '[ -z "$NVIM" ] && nvim -- "{{filename}}" || nvim --server "$NVIM" --remote-send "<Cmd>lua _G._lazygit_edit([==[{{filename}}]==])<CR>"'
  editAtLine: '[ -z "$NVIM" ] && nvim +{{line}} -- "{{filename}}" || nvim --server "$NVIM" --remote-send "<Cmd>lua _G._lazygit_edit([==[{{filename}}]==], {{line}})<CR>"'
gui:
  theme:
    activeBorderColor   : ['%s', 'bold']
    inactiveBorderColor : ['%s']
    selectedLineBgColor : ['%s']
    unstagedChangesColor: ['%s']
]],
    hex("MatchParen",      "fg"),
    hex("FloatBorder",     "fg"),
    hex("Visual",          "bg"),
    hex("DiagnosticError", "fg")
  )

  local temp_config = vim.fn.stdpath("cache") .. "/lazygit-nvim.yml"
  vim.fn.writefile(vim.split(theme_yaml, "\n"), temp_config)

  local term = float_term({ "lazygit" }, {
    width_pct = 0.9,
    height_pct = 0.9,
    title = "Lazygit",
    env = { LG_CONFIG_FILE = temp_config },
  })

  _G._lazygit_edit = function(file, line)
    vim.schedule(function()
      term.close()
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      if line then vim.cmd(tostring(line)) end
    end)
  end
end

-- GitHub issues/PRs picker ====================================================
local function gh_get_id(item) return item and item:match("^#?(%d+)") end

local function selected_id() return gh_get_id(MiniPick.get_picker_matches().current) end

local function gh_run(args)
  vim.fn.jobstart(vim.list_extend({ "gh" }, args), {
    on_exit = function(_, code)
      local msg = table.concat(args, " ")
      if code == 0 then vim.notify("gh " .. msg .. " ✓")
      else vim.notify("gh " .. msg .. " failed", vim.log.levels.ERROR) end
    end,
  })
end

local function on_selected(fn)
  return function()
    local id = selected_id()
    if not id then return end
    MiniPick.stop()
    vim.schedule(function() fn(id) end)
  end
end

local function pr_term(sub)
  return on_selected(function(id)
    float_term({ "gh", "pr", sub, id }, { title = ("PR #%s %s"):format(id, sub) })
  end)
end

function Config.gh_picker(kind, state)
  local cmd = { "gh", kind, "list", "--limit", "50" }
  if state then vim.list_extend(cmd, { "--state", state }) end

  local function open_web(id) vim.fn.jobstart({ "gh", kind, "view", "--web", id }) end

  local mappings = {
    web = {
      char = "<C-o>",
      func = function() local id = selected_id() if id then open_web(id) end end,
    },
  }

  if kind == "pr" then
    mappings.checkout = {
      char = "<C-c>",
      func = on_selected(function(id) gh_run({ "pr", "checkout", id }) end),
    }
    mappings.merge  = { char = "<C-e>", func = pr_term("merge") }
    mappings.diff   = { char = "<C-d>", func = pr_term("diff") }
    mappings.review = { char = "<C-y>", func = pr_term("review") }
  end

  require("mini.pick").builtin.cli({ command = cmd }, {
    source = {
      name = "GitHub " .. kind:upper() .. (state and " (" .. state .. ")" or ""),
      choose = function(item)
        local id = gh_get_id(item)
        if id then open_web(id) end
      end,
    },
    mappings = mappings,
  })
end

-- LanguageTool integration ===================================================
local function get_range(is_visual)
  if not is_visual then return 1, -1 end
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  return math.min(a, b), math.max(a, b)
end

local function locate(lines, first, offset)
  local consumed = 0
  for i, line in ipairs(lines) do
    local len = vim.str_utfindex(line, "utf-16")
    if offset <= consumed + len then
      return first + i - 1, vim.str_byteindex(line, "utf-16", offset - consumed) + 1
    end
    consumed = consumed + len + 1
  end
  return first, 1
end

local function to_qf_item(m, bufnr, lines, first)
  local lnum, col = locate(lines, first, m.offset)

  local before = lines[lnum - first + 1]:sub(1, col - 1)
  if m.rule.id == "WHITESPACE_RULE" and before:match("^%s*$") then return nil end

  local fixes = vim.iter(m.replacements or {}):take(3):map(function(r) return r.value end):totable()
  local hint = #fixes > 0 and ("  -> " .. table.concat(fixes, " | ")) or ""
  return { bufnr = bufnr, lnum = lnum, col = col, type = "W", text = m.message .. hint }
end

local function request(text)
  local out = vim.async.await(3, vim.system, {
    "languagetool-commandline", "--json",
    "-l", "en-US", "-",
  }, {
    text = true,
    stdin = text,
    timeout = 20000,
    env = { JAVA_TOOL_OPTIONS = "-XX:+UseSerialGC -XX:TieredStopAtLevel=1" },
  })
  vim.async.await(1, vim.schedule)
  assert(out.code == 0, "languagetool failed: " .. (out.stderr or ""))
  local json = out.stdout:match("{.*}") -- skip any status lines before the JSON
  return vim.json.decode(json).matches
end

local function run_check(text, bufnr, lines, first)
  local ok, matches = pcall(request, text)
  if not ok then return vim.notify("LanguageTool: " .. tostring(matches), vim.log.levels.ERROR) end

  local seen = {}
  local items = vim.iter(matches)
    :map(function(m) return to_qf_item(m, bufnr, lines, first) end)
    :filter(function(it)
      local key = it.lnum .. ":" .. it.col
      if seen[key] then return false end
      seen[key] = true
      return true
    end)
    :totable()
  if #items == 0 then return vim.notify("No issues found") end

  vim.fn.setqflist({}, " ", { title = "LanguageTool (" .. #items .. ")", items = items })
  vim.cmd.copen()
end

function Config.languagetool_check(is_visual)
  local bufnr = vim.api.nvim_get_current_buf()
  local first, last = get_range(is_visual)
  local lines = vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false)
  local text = table.concat(lines, "\n")

  if not text:find("%S") then return vim.notify("Nothing to check", vim.log.levels.WARN) end

  vim.notify("LanguageTool: checking...")
  vim.async.run(run_check, text, bufnr, lines, first)
end

-- stylua: ignore end
