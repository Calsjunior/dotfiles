vim.opt_local.textwidth = 80

-- Pairs math symbol
local ok_pairs, pairs = pcall(require, "mini.pairs")
if not ok_pairs then return end
pairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })

local ok_keymap, keymap = pcall(require, "mini.keymap")
if not ok_keymap then return end
local jump_after_close_math = keymap.gen_step.search_pattern([=[[)\]}"'`$]\+]=], "ceW", { side = "after" })
local jump_before_open_math = keymap.gen_step.search_pattern([=[[(\[{"'`$]\+]=], "bW")
keymap.map_multistep("i", "<Tab>", { "minisnippets_expand", "minisnippets_next", jump_after_close_math }, { buffer = 0 })
keymap.map_multistep("i", "<S-Tab>", { "minisnippets_prev", jump_before_open_math, }, { buffer = 0 })
