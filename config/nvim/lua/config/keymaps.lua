local Fn = require("config.functions")
local map = vim.keymap.set

-- stylua: ignore start
local nmap = function(lhs, rhs, desc, opts) map("n", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {})) end
local xmap = function(lhs, rhs, desc, opts) map("x", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {})) end
local nmap_leader = function(sfx, rhs, desc, opts) map("n", "<leader>" .. sfx, rhs, vim.tbl_extend("force", { desc = desc }, opts or {})) end
local xmap_leader = function(sfx, rhs, desc, opts) map("x", "<leader>" .. sfx, rhs, vim.tbl_extend("force", { desc = desc }, opts or {})) end

-- Basic mappings =============================================================
map({ "n", "i" }, "<Esc>", "<Cmd>noh<CR><Esc>", { desc = "Escape and clear hlsearch" })
nmap("Y", "y$", "Yank to end of line")

nmap("H", "_", "Start of line (non-blank)")
nmap("L", "$", "End of line (non-blank)")

nmap("<C-S-l>", "<cmd>bnext<CR>", "Buffer Next")
nmap("<C-S-h>", "<cmd>bprevious<CR>", "Buffer Previous")

-- Linewise pasting (pastes on a new line regardless of how you yanked it)
nmap("[p", function() vim.cmd("put!" .. vim.v.register) end, "Paste Above")
nmap("]p", function() vim.cmd("put" .. vim.v.register)  end, "Paste Below")

-- Diagnostic Navigation
nmap("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous Diagnostic")
nmap("]d", function() vim.diagnostic.jump({ count = 1 })  end, "Next Diagnostic")
nmap("[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, "Previous Error")
nmap("]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })  end, "Next Error")

--- Spliting ------------------------------------------------------------------
nmap("<C-h>", function() require("smart-splits").move_cursor_left()  end, "Move to left split")
nmap("<C-j>", function() require("smart-splits").move_cursor_down()  end, "Move to below split")
nmap("<C-k>", function() require("smart-splits").move_cursor_up()    end, "Move to above split")
nmap("<C-l>", function() require("smart-splits").move_cursor_right() end, "Move to right split")

nmap("<A-C-h>", function() require("smart-splits").resize_left()     end, "Resize split left")
nmap("<A-C-j>", function() require("smart-splits").resize_down()     end, "Resize split down")
nmap("<A-C-k>", function() require("smart-splits").resize_up()       end, "Resize split up")
nmap("<A-C-l>", function() require("smart-splits").resize_right()    end, "Resize split right")

-- Incremental Selection (Treesitter + LSP) ===================================
xmap("[n", function() vim.treesitter.select("prev", vim.v.count1)        end, "Select previous node")
xmap("]n", function() vim.treesitter.select("next", vim.v.count1)        end, "Select next node")
xmap("[N", function() vim.treesitter.select("extend_prev", vim.v.count1) end, "Select previous sibling node")
xmap("]N", function() vim.treesitter.select("extend_next", vim.v.count1) end, "Select next sibling node")
map({ "n", "x", "o" }, "=", Fn.ts_or_lsp("parent", 1), { desc = "Grow selection (parent node)" })
map({ "n", "x", "o" }, "-", Fn.ts_or_lsp("child", -1), { desc = "Shrink selection (child node)" })

-- Leader group clues =========================================================
local M = {}
M.leader_group_clues = {
  { mode = "n", keys = "<leader>b",  desc = "+buffer" },
  { mode = "n", keys = "<leader>c",  desc = "+config" },
  { mode = "n", keys = "<leader>e",  desc = "+explore" },
  { mode = "n", keys = "<leader>f",  desc = "+find" },
  { mode = "n", keys = "<leader>g",  desc = "+git" },
  { mode = "n", keys = "<leader>gh", desc = "+hunk/diff" },
  { mode = "n", keys = "<leader>i",  desc = "+insert" },
  { mode = "n", keys = "<leader>l",  desc = "+language" },
  { mode = "n", keys = "<leader>n",  desc = "+neovim/system" },
  { mode = "n", keys = "<leader>q",  desc = "+quit/session" },
  { mode = "n", keys = "<leader>r",  desc = "+run" },
  { mode = "n", keys = "<leader>s",  desc = "+search" },
  { mode = "n", keys = "<leader>t",  desc = "+terminal" },
  { mode = "n", keys = "<leader>v", desc = "+visits/bookmarks" },
  { mode = "n", keys = "<leader>w",  desc = "+window" },
}

-- b is for 'Buffer' ----------------------------------------------------------
nmap_leader("ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader("bd", function() require("mini.bufremove").delete(0, false)  end, "Delete")
nmap_leader("bD", function() require("mini.bufremove").delete(0, true)   end, "Delete!")
nmap_leader("bw", function() require("mini.bufremove").wipeout(0, false) end, "Wipeout")
nmap_leader("bW", function() require("mini.bufremove").wipeout(0, true)  end, "Wipeout!")
nmap_leader("bs", function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end, "Scratch")
nmap_leader("bo", Fn.close_other_buffers, "Close Others")
nmap_leader("bl", Fn.close_buffers_left,  "Close Left")
nmap_leader("br", Fn.close_buffers_right, "Close Right")

-- c is for 'Config' ----------------------------------------------------------
nmap_leader("cs", "<cmd>w<CR>",               "Save file")
nmap_leader("cn", "<cmd>noautocmd write<CR>", "Save without formatting")
nmap_leader("cx", Fn.source_project_config,   "Source project .nvim.lua")

-- e is for 'Explore' ---------------------------------------------------------
nmap_leader("e.", "<cmd>Yazi<CR>",     "Open yazi (current file dir)")
nmap_leader("ee", "<cmd>Yazi cwd<CR>", "Open yazi (cwd)")
nmap_leader("eq", function() vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen') end, "Quickfix")
nmap_leader("eQ", function() vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen') end, "Locations")

-- f is for 'Find' ------------------------------------------------------------
nmap_leader("f.", function() require("mini.pick").builtin.files(nil, { source = { cwd = vim.fn.expand("%:p:h") } }) end, "Find files (current file dir)")
nmap_leader("ff", "<Cmd>Pick files<CR>",                     "Find files (cwd)")
nmap_leader("fh", "<Cmd>Pick help<CR>",                      "Help Pages")
nmap_leader("fr", "<Cmd>Pick oldfiles<CR>",                  "Find Recent")
nmap_leader("fb", "<Cmd>Pick buffers<CR>",                   "Buffers")
nmap_leader("fl", '<Cmd>Pick buf_lines scope="all"<CR>',     "Lines (all buffers)")
nmap_leader("fL", '<Cmd>Pick buf_lines scope="current"<CR>', "Lines (current buffer)")
nmap_leader("fR", "<Cmd>Pick resume<CR>",                    "Resume last picker")
nmap_leader("fv", '<Cmd>Pick visit_paths cwd=""<CR>',        "Visit paths (all)")
nmap_leader("fV", '<Cmd>Pick visit_paths<CR>',               "Visit paths (cwd)")

-- g is for 'Git' -------------------------------------------------------------
nmap_leader("ghs", "ghgh",     "Stage Hunk",   { remap = true })
nmap_leader("ghr", "gHgh",     "Reset Hunk",   { remap = true })
nmap_leader("ghR", function() local view = vim.fn.winsaveview() vim.cmd("keepjumps normal ggVGgH") vim.fn.winrestview(view) end, "Reset Buffer")
nmap_leader("gc",  "<Cmd>Pick git_commits<CR>",          "Commits (all)")
nmap_leader("gC",  '<Cmd>Pick git_commits path="%"<CR>', "Commits (buffer)")
nmap_leader("gd",  "<Cmd>Pick git_hunks<CR>",            "Modified hunks (workspace)")
nmap_leader("gD",  '<Cmd>Pick git_hunks path="%"<CR>',   "Modified hunks (buffer)")
nmap_leader("ghb", function() require("mini.git").show_at_cursor()      end, "Blame Line")
nmap_leader("ghp", function() require("mini.diff").toggle_overlay()     end, "Preview Hunks (Overlay)")
nmap_leader("gg",  Fn.lazygit,                                               "Lazygit")
nmap_leader("gb",  Fn.gitbrowse,                                             "Browse")
xmap_leader("gb",  function() Fn.gitbrowse(true)                        end, "Browse (selection)")
nmap_leader("gi",  function() Fn.gh_picker("issue")                     end, "Issues (open)")
nmap_leader("gI",  function() Fn.gh_picker("issue", "all")              end, "Issues (all)")
nmap_leader("gp",  function() Fn.gh_picker("pr")                        end, "PRs (open)")
nmap_leader("gP",  function() Fn.gh_picker("pr", "all")                 end, "PRs (all)")

-- i is for 'Insert' ----------------------------------------------------------
nmap_leader("is", Fn.insert_snippet, "Insert Snippet")

-- l is for 'Language' --------------------------------------------------------
nmap_leader("la", vim.lsp.buf.code_action,                    "Code action")
nmap_leader("lr", vim.lsp.buf.rename,                         "Rename")
nmap_leader("lh", vim.lsp.buf.hover,                          "Hover documentation")
nmap_leader("ld", vim.diagnostic.open_float,                  "Line diagnostics float")
nmap_leader("lD", '<Cmd>Pick diagnostic scope="current"<CR>', "Buffer diagnostics (Picker)")
nmap_leader("lw", '<Cmd>Pick diagnostic scope="all"<CR>',     "Workspace diagnostics (Picker)")
nmap_leader("lf", function() require("conform").format() end, "Format")
xmap_leader("lf", function() require("conform").format() end, "Format selection")

nmap_leader("ls", '<Cmd>Pick lsp scope="definition"<CR>',            "Source definition")
nmap_leader("lR", '<Cmd>Pick lsp scope="references"<CR>',            "References")
nmap_leader("li", '<Cmd>Pick lsp scope="implementation"<CR>',        "Implementation")
nmap_leader("lt", '<Cmd>Pick lsp scope="type_definition"<CR>',       "Type definition")
nmap_leader("lo", '<Cmd>Pick lsp scope="document_symbol"<CR>',       "Document Symbols (Outline)")
nmap_leader("lO", '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>', "Workspace Symbols")

-- n is for 'Neovim' ----------------------------------------------------------
nmap_leader("nl", "<cmd>Lazy<CR>", "Open Lazy UI")
nmap_leader("nc", "<cmd>checkhealth lsp<CR>", "Checkhealth LSP")
nmap_leader("nr", "<cmd>restart<CR>", "Restart Neovim")

-- r is for 'Run' -------------------------------------------------------------
nmap_leader("r", Fn.run_current_file, "Run/Compile Current File")

-- q is for 'Quit / Session' --------------------------------------------------
nmap_leader("qq", "<cmd>qa<CR>", "Quit All")
nmap_leader("qs", function()
  vim.ui.input({ prompt = "Session: ", default = vim.fs.basename(vim.uv.cwd()) }, function(n)
    if n and n ~= "" then require("mini.sessions").write(n, { force = true }) end
  end)
end, "Save Session")
nmap_leader("ql", function() require("mini.sessions").select()         end, "Load Session")
nmap_leader("qd", function() require("mini.sessions").select("delete") end, "Delete Session")

-- s is for 'Search' ----------------------------------------------------------
nmap_leader("s.", function() require("mini.pick").builtin.grep_live(nil, { source = { cwd = vim.fn.expand("%:p:h") } }) end, "Grep (current file dir)")
nmap_leader("sg", "<Cmd>Pick grep_live<CR>", "Grep (cwd)")
nmap_leader("s:", '<Cmd>Pick history scope=":"<CR>', "Command History")
nmap_leader("sn", function() require("mini.notify").show_history() end, "Notifications")
nmap_leader("sw", '<Cmd>Pick grep pattern="<cword>"<CR>', "Grep word")
nmap_leader("st", '<Cmd>Pick grep pattern="TODO|FIXME|HACK|NOTE"<CR>', "TODOs (Project)")
nmap_leader("sr", function() -- Simulate grugfar behavior using mini.pick + quickfix
  vim.ui.input({ prompt = "Replace: " }, function(search)
    if not search or search == "" then return end
    vim.ui.input({ prompt = "With: " }, function(replace)
      if not replace then return end
      vim.cmd(string.format("cdo s/%s/%s/ge | update", search, replace))
    end)
  end)
end, "Replace in Quickfix lines")

-- t is for 'Terminal' (Kitty splits/tabs) ------------------------------------
nmap_leader("tv", function() Fn.kitty_launch("--location=vsplit") end, "Kitty Split Vertical")
nmap_leader("ts", function() Fn.kitty_launch("--location=hsplit", "kitty @ resize-window --axis vertical --increment -5") end, "Kitty Split Horizontal")
nmap_leader("tt", function() Fn.kitty_launch("--type=tab") end, "Kitty New Tab")

-- v is for 'Visits' ----------------------------------------------------------
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = require("mini.visits").gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
    require("mini.extra").pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader("vc", make_pick_core("", "Core visits (all)"),                    "Core visits (all)")
nmap_leader("vC", make_pick_core(nil, "Core visits (cwd)"),                   "Core visits (cwd)")
nmap_leader("vv", function() require("mini.visits").add_label("core")    end, "Add 'core' label")
nmap_leader("vV", function() require("mini.visits").remove_label("core") end, "Remove 'core' label")
nmap_leader("vl", function() require("mini.visits").add_label()          end, "Add label")
nmap_leader("vL", function() require("mini.visits").remove_label()       end, "Remove label")

-- w is for 'Window' ----------------------------------------------------------
nmap_leader("wv", "<cmd>vsplit<CR>", "Split window vertically")
nmap_leader("ws", "<cmd>split<CR>",  "Split window Horizontally")
nmap_leader("wd", "<cmd>close<CR>",  "Delete current window")

return M

-- stylua: ignore end
