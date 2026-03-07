return {
    "mikavilpas/yazi.nvim",
    init = function()
        vim.g.loaded_netrwPlugin = 1
    end,
    event = "VeryLazy",
    opts = {
        open_for_directories = true,
    },
}
