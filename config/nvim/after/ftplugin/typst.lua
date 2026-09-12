vim.opt_local.textwidth = 80

-- Pairs math symbol
local ok, pairs = pcall(require, "mini.pairs")
if ok then
  pairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })
end
