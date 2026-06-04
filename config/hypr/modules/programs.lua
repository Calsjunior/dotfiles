local terminal = "kitty -1"

return {
    terminal = terminal,
    fileManager = terminal .. " yazi",
    browser = "zen-beta",
    editor = terminal .. " nvim",
    session = [[kitty -1 -e zsh -c "nvim +\"lua vim.schedule(function() vim.api.nvim_input('s') end)\""]],
    pacman = terminal .. " pacseek",
    scripts = os.getenv("HOME") .. "/.config/hypr/scripts",
}
