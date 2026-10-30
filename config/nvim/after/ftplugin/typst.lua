-- stylua: ignore start
vim.opt_local.textwidth = 80

-- pdf viewer to use (string or list)
-- set value to 'nil' to fallback to xdg-open which can't be attached to the
-- watcher (stopping typst when pdf_viewer closes).
local pdf_viewer = "zathura"

local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc }) end

-- Math pairs / jumping (needs mini.pairs, mini.keymap to be enabled)
local function setup_math_pairs()
  local ok_pairs, mini_pairs = pcall(require, "mini.pairs")
  if not ok_pairs then return end
  mini_pairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })

  local ok_keymap, keymap = pcall(require, "mini.keymap")
  if not ok_keymap then return end
  local jump_after_close_math = keymap.gen_step.search_pattern([=[[)\]}"'`$]\+]=], "ceW", { side = "after" })
  local jump_before_open_math = keymap.gen_step.search_pattern([=[[(\[{"'`$]\+]=], "bW")
  keymap.map_multistep("i", "<Tab>", { "minisnippets_expand", "minisnippets_next", jump_after_close_math }, { buffer = 0 })
  keymap.map_multistep("i", "<S-Tab>", { "minisnippets_prev", jump_before_open_math }, { buffer = 0 })
end

setup_math_pairs()

-- Heading navigation
map("]H", function() vim.fn.search([[^=\+\s]], "W")  end, "Next heading")
map("[H", function() vim.fn.search([[^=\+\s]], "bW") end, "Previous heading")

-- typst watcher
local async = vim.async

local jobs = _G.typst_jobs
if not jobs then
  jobs = {}
  _G.typst_jobs = jobs
  Config.new_autocmd("VimLeavePre", "*", function()
    for _, j in pairs(jobs) do
      j.watch:kill(2)
      if j.viewer then j.viewer:kill(15) end
    end
  end, "Kill typst watchers on exit")
end

local function target()
  local here = vim.api.nvim_buf_get_name(0)
  local main = vim.fs.find("main.typ", { upward = true, path = vim.fs.dirname(here) })[1]
  return main or here
end

local function stop(t)
  local j = jobs[t]
  if not j then return end
  jobs[t] = nil
  if j.opener then j.opener:close() end
  j.watch:kill(2)
  if j.viewer then j.viewer:kill(15) end
  vim.notify("typst watch stopped")
end

local function viewer_argv(pdf)
  local v = pdf_viewer or "xdg-open"
  local argv = type(v) == "table" and vim.deepcopy(v) or { v }
  table.insert(argv, pdf)
  return argv
end

local function start(t)
  local cmd = { "typst", "watch" }

  local root_rel = vim.b.typst_root or vim.g.typst_root
  if root_rel then
    local root = vim.uv.fs_realpath(vim.fs.dirname(t) .. "/" .. root_rel)
    if not root then
      return vim.notify("typst root not found: " .. root_rel, vim.log.levels.ERROR)
    end
    vim.list_extend(cmd, { "--root", root })
  end
  table.insert(cmd, t)

  local job = {}
  job.watch = vim.system(cmd, {
    text = true,
    stdout = false,
    stderr = function(_, data)
      if not data or not data:find("error") then return end
      vim.schedule(function() vim.notify(data, vim.log.levels.ERROR) end)
    end,
  }, function()
    if jobs[t] == job then jobs[t] = nil end -- watcher died on its own
  end)
  jobs[t] = job

  local pdf = (t:gsub("%.typ$", ".pdf"))

  job.opener = async.run(function()
    local timeout_ms, interval_ms = 5000, 100
    for _ = 1, timeout_ms / interval_ms do
      if vim.uv.fs_stat(pdf) then break end
      async.sleep(interval_ms)
    end
    if not vim.uv.fs_stat(pdf) then
      return vim.notify("typst produced no PDF, check errors", vim.log.levels.WARN)
    end

    -- xdg-open exits right away, so no watcher should be attached to it
    if not pdf_viewer then
      vim.system(viewer_argv(pdf), { detach = true })
      return
    end

    job.viewer = vim.system(viewer_argv(pdf), { detach = true }, function()
      if jobs[t] ~= job then return end
      jobs[t] = nil
      job.watch:kill(2)
      vim.schedule(function() vim.notify("viewer closed, typst watch stopped") end)
    end)
  end)

  vim.notify("typst watch: " .. vim.fs.basename(t))
end

map("<leader>lp", function() local t = target() if jobs[t] then return stop(t) end start(t) end, "Typst: toggle watch")
-- stylua: ignore end
