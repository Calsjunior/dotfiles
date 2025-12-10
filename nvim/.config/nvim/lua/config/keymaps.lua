-- Add comma after brackets
vim.keymap.set("i", "<C-,>", function()
    local line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local next_char = line:sub(col + 1, col + 1)

    if next_char == "}" or next_char == "]" or next_char == ")" then
        -- Modify the line directly
        local new_line = line:sub(1, col + 1) .. "," .. line:sub(col + 2)
        vim.api.nvim_set_current_line(new_line)
    end
end, { desc = "Add comma after bracket" })

-- Add semicolon at end of line
vim.keymap.set("i", "<C-;>", function()
    local line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Simply add semicolon at end of line if it doesn't already have one
    if not line:match(";%s*$") then
        vim.api.nvim_set_current_line(line .. ";")
    end
end, { desc = "Add semicolon at end of line" })

-- Buffer
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
vim.keymap.set("n", "th", "<cmd>bprev<CR>", { desc = "Prev Buffer" })
vim.keymap.set("n", "tl", "<cmd>bnext<CR>", { desc = "Next Buffer" })

-- Beginning and End of line
vim.keymap.set("n", "H", "g^", { desc = "Start of line (non-blank)" })
vim.keymap.set("n", "L", "g$", { desc = "End of line (non-blank)" })

-- Save without formatting
vim.keymap.set("n", "<leader>wn", "<cmd>noautocmd write<CR>", { desc = "Save without formatting" })
