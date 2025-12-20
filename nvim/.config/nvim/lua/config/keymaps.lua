local map = vim.keymap.set

-- General
map("n", "<leader>o", "<cmd>update<CR><cmd>source %<CR>")
map("n", "th", "<cmd>bprev<CR>", { desc = "Prev Buffer" })
map("n", "tl", "<cmd>bnext<CR>", { desc = "Next Buffer" })

-- Movement
map("n", "H", "g^", { desc = "Start of line (non-blank)" })
map("n", "L", "g$", { desc = "End of line (non-blank)" })

-- Plugins
map("n", "<leader>wn", "<cmd>noautocmd write<CR>", { desc = "Save without formatting" })
map("n", "<leader>e", "<cmd>Yazi<CR>")
map("n", "<leader>E", "<cmd>Yazi cwd<CR>")
