return {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
        -- Define the select_one_or_multi function
        local select_one_or_multi = function(prompt_bufnr)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            local multi = picker:get_multi_selection()
            if not vim.tbl_isempty(multi) then
                require("telescope.actions").close(prompt_bufnr)
                for _, j in pairs(multi) do
                    if j.path ~= nil then
                        vim.cmd(string.format("%s %s", "edit", j.path))
                    end
                end
            else
                require("telescope.actions").select_default(prompt_bufnr)
            end
        end

        -- Merge with existing defaults or create new ones
        opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
            mappings = {
                i = {
                    -- Override <CR> to use our multi-select function
                    ["<CR>"] = select_one_or_multi,
                    -- Keep tab for multi-select (default behavior)
                    ["<Tab>"] = require("telescope.actions").toggle_selection
                        + require("telescope.actions").move_selection_worse,
                    ["<S-Tab>"] = require("telescope.actions").toggle_selection
                        + require("telescope.actions").move_selection_better,
                },
                n = {
                    -- Also work in normal mode
                    ["<CR>"] = select_one_or_multi,
                    ["<Tab>"] = require("telescope.actions").toggle_selection
                        + require("telescope.actions").move_selection_worse,
                    ["<S-Tab>"] = require("telescope.actions").toggle_selection
                        + require("telescope.actions").move_selection_better,
                },
            },
        })

        -- Add <leader>fh to find hidden files
        vim.keymap.set("n", "<leader>fh", function()
            require("telescope.builtin").find_files({
                hidden = true,
                no_ignore = true,
            })
        end, { desc = "Find Files (hidden)" })

        return opts
    end,
}
