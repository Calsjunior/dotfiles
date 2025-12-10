return {
    {
        "mikavilpas/yazi.nvim",
        lazy = false,
        keys = {
            {
                "<leader>e",
                function()
                    require("yazi").yazi()
                end,
                desc = "Toggle Yazi (root dir)",
            },
            {
                "<leader>E",
                function()
                    require("yazi").yazi(nil, vim.fn.getcwd())
                end,
                desc = "Toggle Yazi (cwd)",
            },
        },
        opts = {
            open_for_directories = true,
        },
    },
}
