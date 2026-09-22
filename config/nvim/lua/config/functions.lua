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

function Config.close_other_buffers()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(listed_buffers()) do
    if buf ~= cur then
      MiniBufremove.delete(buf, false)
    end
  end
end

function Config.close_buffers_right()
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

function Config.close_buffers_left()
  for _, buf in ipairs(listed_buffers()) do
    if buf == vim.api.nvim_get_current_buf() then
      break
    end
    MiniBufremove.delete(buf, false)
  end
end

-- Compile/run current file ===================================================
function Config.compile_and_run(compiler, ext)
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

function Config.run_current_file()
  vim.cmd("silent! w")
  local ft = vim.bo.filetype

  local runners = {
    javascript = "node " .. vim.fn.shellescape(vim.fn.expand("%:p")),
    python = "python3 " .. vim.fn.shellescape(vim.fn.expand("%:p")),
    sh = "bash " .. vim.fn.shellescape(vim.fn.expand("%:p")),
    c = function()
      return Config.compile_and_run("gcc", "c")
    end,
    cpp = function()
      return Config.compile_and_run("g++", "cpp")
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

-- Project-local config execution =============================================
function Config.source_project_config()
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
function Config.kitty_launch(args, post_cmd)
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
function Config.gitbrowse(is_visual)
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

function Config.lazygit()
  local function hex(hl_name, attr)
    local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
    return hl[attr] and string.format("#%06x", hl[attr]) or "default"
  end
  -- stylua: ignore
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

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local buf = vim.api.nvim_create_buf(false, true)

  -- stylua: ignore
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = width, height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal", border = "rounded",
    title = " Lazygit ", title_pos = "center",
  })

  _G._lazygit_edit = function(file, line)
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      if line then
        vim.cmd(tostring(line))
      end
    end)
  end

  Config.new_autocmd("VimResized", nil, function()
    if not vim.api.nvim_win_is_valid(win) then
      return
    end
    local new_width = math.floor(vim.o.columns * 0.9)
    local new_height = math.floor(vim.o.lines * 0.9)
    vim.api.nvim_win_set_config(win, {
      relative = "editor",
      width = new_width,
      height = new_height,
      row = math.floor((vim.o.lines - new_height) / 2),
      col = math.floor((vim.o.columns - new_width) / 2),
    })
  end)

  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    env = { LG_CONFIG_FILE = temp_config },
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })

  vim.cmd("startinsert")
end

function Config.gh_picker(type, state)
  local cmd = { "gh", type, "list", "--limit", "50" }
  if state then
    vim.list_extend(cmd, { "--state", state })
  end

  require("mini.pick").builtin.cli({ command = cmd }, {
    source = {
      name = "GitHub " .. type:upper() .. (state and " (" .. state .. ")" or ""),
      choose = function(item)
        local id = item:match("^#?(%d+)")
        if id then
          vim.fn.jobstart({ "gh", type, "view", "--web", id })
        end
      end,
    },
  })
end
