local apps = require("modules.programs")

hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 1 && " .. apps.terminal .. " --start-as=hidden")

    -- Quickshell/Caelestia Shell
    hl.exec_cmd("caelestia shell -d")
    hl.exec_cmd(apps.scripts .. "/theme-bridge.sh")

    -- XDPH
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Clipboard Manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Authentication Agent & Display
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("gammastep -P -O 4570")
end)
