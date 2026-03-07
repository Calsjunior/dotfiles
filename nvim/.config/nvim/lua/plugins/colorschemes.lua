-- This config uses the script from theme-bridge.lua from my dotfile
-- to dynamically update neovim's theme while lazy loading unused themes
local theme_file = vim.fn.stdpath("config") .. "/lua/config/current_theme.lua"
local current_theme = ""
if vim.fn.filereadable(theme_file) == 1 then
    local ok, content = pcall(vim.fn.readfile, theme_file)
    if ok then
        current_theme = table.concat(content, "\n")
    end
end

return {
    { "neanias/everforest-nvim", lazy = not current_theme:find("everforest"), priority = 1000 },
    { "folke/tokyonight.nvim", lazy = not current_theme:find("tokyonight"), priority = 1000 },
    { "catppuccin/nvim", lazy = not current_theme:find("catppuccin"), priority = 1000 },
    { "sainnhe/gruvbox-material", lazy = not current_theme:find("gruvbox"), priority = 1000 },
}
