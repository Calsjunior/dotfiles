return {
    {
        "goerz/jupytext.vim",
        config = function()
            vim.g.jupytext_fmt = "py:percent"
        end,
    },
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        init = function()
            vim.g.molten_image_provider = "none"
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_auto_open_output = true
            vim.g.molten_output_win_style = "split"
            vim.g.molten_enter_output_behavior = "open_then_enter"
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
        end,
        keys = {
            { "<leader>ji", ":MoltenInit<CR>", silent = true, desc = "Initialize Molten Kernel" },
            { "<leader>je", ":MoltenEvaluateOperator<CR>", silent = true, desc = "Evaluate Operator" },
            { "<leader>jl", ":MoltenEvaluateLine<CR>", silent = true, desc = "Evaluate Line" },
            { "<leader>jr", ":MoltenReevaluateCell<CR>", silent = true, desc = "Re-evaluate Cell" },
            { "<leader>jo", ":MoltenShowOutput<CR>", silent = true, desc = "Show Output" },
            { "<leader>jd", ":MoltenDelete<CR>", silent = true, desc = "Delete Output" },
            {
                "<leader>jv",
                ":<C-u>MoltenEvaluateVisual<CR>gv",
                mode = "v",
                silent = true,
                desc = "Evaluate Visual Selection",
            },
            {
                "<leader>jc",
                function()
                    local cursor = vim.api.nvim_win_get_cursor(0)
                    local line = cursor[1]
                    local total_lines = vim.api.nvim_buf_line_count(0)
                    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

                    local start_line = 1
                    for i = line - 1, 1, -1 do
                        if lines[i]:match("^# %%") then
                            start_line = i + 1
                            break
                        end
                    end

                    local end_line = total_lines
                    for i = line, total_lines do
                        if lines[i]:match("^# %%") and i > start_line then
                            end_line = i - 1
                            break
                        end
                    end

                    -- Trim trailing blank lines
                    while end_line > start_line and lines[end_line]:match("^%s*$") do
                        end_line = end_line - 1
                    end

                    vim.fn.MoltenEvaluateRange(start_line, end_line)
                end,
                silent = true,
                desc = "Evaluate Cell",
            },
            {
                "<leader>ja",
                function()
                    vim.fn.MoltenEvaluateRange(1, vim.api.nvim_buf_line_count(0))
                end,
                silent = true,
                desc = "Evaluate All Cells",
            },
        },
    },
}
