local terminal = "kitty -1"

return {
    terminal = terminal,
    fileManager = terminal .. " yazi",
    browser = "zen-browser",
    editor = terminal .. " nvim",
    session = [[kitty -1 -e zsh -c "nvim +\"lua vim.schedule(function() vim.api.nvim_input('s') end)\""]],
    pacman = terminal .. " pacseek",
    menu = "caelestia shell drawers toggle launcher",
    power_menu = "caelestia shell drawers toggle session",
    dashboard = "caelestia shell drawers toggle dashboard",
    notif_clear = "caelestia shell notifs clear",
    scripts = os.getenv("HOME") .. "/.config/hypr/scripts",
}
