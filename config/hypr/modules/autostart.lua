local apps = require("modules.programs")

hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 1 && " .. apps.terminal .. " --start-as=hidden")

    hl.exec_cmd(apps.desktopShell)

    -- Clipboard Manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
