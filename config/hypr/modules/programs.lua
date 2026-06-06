local terminal = "kitty -1"
local ipc = "noctalia msg"

return {
    terminal = terminal,
    fileManager = terminal .. " yazi",
    browser = "zen-beta",
    desktopShell = "noctalia",
    editor = terminal .. " nvim",
    session = [[kitty -1 -e zsh -c "nvim +\"lua vim.schedule(function() vim.api.nvim_input('s') end)\""]],
    scripts = os.getenv("HOME") .. "/.config/hypr/scripts",
    ipc = ipc,
}
