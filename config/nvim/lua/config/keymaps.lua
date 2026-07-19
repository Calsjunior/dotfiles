local map = vim.keymap.set

-- ==========
-- General
-- ==========

-- Editing
map("n", "<leader>cs", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>cn", "<cmd>noautocmd write<CR>", { desc = "Save without formatting" })
map("n", "Y", "y$", { desc = "Yank to end of line" })
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Center screen when jumping
-- map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
-- map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
-- map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
-- map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer mappings
map("n", "<leader>o", "<cmd>update<CR><cmd>source %<CR><cmd>nohlsearch<CR>")
map("n", "<C-S-l>", "<cmd>bnext<CR>")
map("n", "<C-S-h>", "<cmd>bprevious<CR>")

-- Move lines up and down
map("n", "<C-S-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("v", "<C-S-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
map("n", "<C-S-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("v", "<C-S-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Better indenting in visual mode
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Movement
map("n", "H", "_", { desc = "Start of line (non-blank)" })
map("n", "L", "$", { desc = "End of line (non-blank)" })

-- Compiling/Running current file
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("silent! w")

  local ft = vim.bo.filetype
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  local file_no_ext = vim.fn.shellescape(vim.fn.expand("%:p:r"))
  local dir = vim.fn.shellescape(vim.fn.expand("%:p:h"))
  local raw_dir = vim.fn.expand("%:p:h")

  local function compile_and_run(compiler, ext)
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

  local runners = {
    javascript = "node " .. file,
    python = "python3 " .. file,
    sh = "bash " .. file,
    c = function()
      return compile_and_run("gcc", "c")
    end,
    cpp = function()
      return compile_and_run("g++", "cpp")
    end,
  }

  local runner = runners[ft]
  if not runner then
    vim.notify("No run command configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local cmd
  if type(runner) == "function" then
    cmd = runner()
  else
    cmd = runner
  end
  if not cmd then
    return
  end

  vim.cmd("botright 15new")
  vim.fn.jobstart(cmd, { term = true })
  vim.cmd("startinsert")
end, { desc = "Run/Compile Current File" })

-- Inserting snippets
vim.keymap.set("n", "<leader>is", function()
  -- NOTE: Change these path to your specific folders
  local base_dir = "~/dev"
  local ft_map = {
    html = "web/snippets/html",
    css = "web/snippets/css",
    javascript = "web/snippets/js",
    c = "c/snippets",
    cpp = "cpp/snippets",
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
        -- Insert content at cursor without blank lines above or below
        local full_path = snippet_dir .. "/" .. item.file
        local lines = vim.fn.readfile(full_path)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local is_empty = vim.api.nvim_get_current_line():match("^%s*$") ~= nil
        vim.api.nvim_buf_set_lines(0, row - 1, is_empty and row or (row - 1), false, lines)
      end
    end,
  })
end, { desc = "Insert Snippet" })

-- Plugins
-- Yazi
map("n", "<leader>e", "<cmd>Yazi<CR>", { desc = "Open Yazi (Current File)" })
map("n", "<leader>E", "<cmd>Yazi cwd<CR>", { desc = "Open Yazi (cwd)" })

-- Find Files
map("n", "<leader>ff", function()
  Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Find Files (Current File)" })

map("n", "<leader>fF", function()
  Snacks.picker.files({ cwd = vim.fn.getcwd() })
end, { desc = "Find Files (cwd)" })

map("n", "<leader>fh", function()
  Snacks.picker.files({ cwd = vim.fn.expand("~") })
end, { desc = "Find Files (Home)" })

-- Grep
map("n", "<leader>sg", function()
  Snacks.picker.grep({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Grep (Current File)" })

map("n", "<leader>sG", function()
  Snacks.picker.grep({ cwd = vim.fn.getcwd() })
end, { desc = "Grep (cwd)" })

map("n", "<leader>sH", function()
  Snacks.picker.grep({ cwd = vim.fn.expand("~") })
end, { desc = "Grep (Home)" })

map("n", "<leader>cx", function()
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
end, { desc = "Source project .nvim.lua" })

-- Helper function for Kitty IPC
local function kitty_launch(args, post_cmd)
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end

  local cmd = string.format("kitty @ launch %s --cwd=%s", args, vim.fn.shellescape(dir))
  vim.fn.system(cmd)

  if post_cmd then
    vim.fn.system(post_cmd)
  end
end

-- Terminal Splits & Tabs
map("n", "<leader>tv", function()
  kitty_launch("--location=vsplit")
end, { desc = "Kitty Split Vertical" })

map("n", "<leader>ts", function()
  kitty_launch("--location=hsplit", "kitty @ resize-window --axis vertical --increment -5")
end, { desc = "Kitty Split Horizontal" })

map("n", "<leader>tt", function()
  kitty_launch("--type=tab")
end, { desc = "Kitty New Tab" })
