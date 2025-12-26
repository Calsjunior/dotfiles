local map = vim.keymap.set

-- ==========
-- General
-- ==========

-- Editing
map("n", "Y", "y$", { desc = "Yank to end of line" })
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Center screen when jumping
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer mappings
map("n", "<leader>o", "<cmd>update<CR><cmd>source %<CR><cmd>nohlsearch<CR>")
map("n", "tn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "tp", "<cmd>bprev<CR>", { desc = "Prev Buffer" })

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

-- Plugins
map("n", "<leader>wn", "<cmd>noautocmd write<CR>", { desc = "Save without formatting" })
map("n", "<leader>e", "<cmd>Yazi<CR>", { desc = "Open Yazi (cwd)" })
map("n", "<leader>E", "<cmd>Yazi cwd<CR>", { desc = "Open Yazi (Root Dir)" })
map("n", "<leader>ff", function()
    Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Find Files (cwd)" })
map("n", "<leader>fF", function()
    Snacks.picker.files({ cwd = vim.fn.getcwd() })
end, { desc = "Find Files (Root Dir)" })
map("n", "<leader>fh", function()
    Snacks.picker.files({ cwd = vim.fn.expand("~") })
end, { desc = "Find Files (Home)" })
map("n", "<leader>sg", function()
    Snacks.picker.grep({ cwd = vim.fn.getcwd() })
end, { desc = "Grep (cwd)" })
map("n", "<leader>sG", function()
    Snacks.picker.grep({ cwd = vim.fn.expand("~") })
end, { desc = "Grep (Home)" })
map({ "n", "t" }, "<C-/>", function()
    Snacks.terminal.toggle(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (cwd)" })
map({ "n", "t" }, "<C-S-/>", function()
    Snacks.terminal.toggle(nil, { cwd = vim.fn.getcwd() })
end, { desc = "Terminal (Root Dir)" })
