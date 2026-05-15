local apps = require("modules.programs")
local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(apps.terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(apps.editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(apps.browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(apps.fileManager))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(apps.pacman))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(apps.session))

-- Caelestia & Scripts
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(apps.menu))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(apps.power_menu))
hl.bind(mainMod .. " + ALT + Q", function()
    local w = hl.get_active_window()
    if w ~= nil then
        os.execute("kill " .. w.pid)
    end
end)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(apps.dashboard))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(apps.scripts .. "/wallpaper.sh"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd(apps.scripts .. "/scheme.sh"))
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd(apps.notif_clear))

-- Clipboard & Emoji
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

-- Utilities
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("caelestia screenshot"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.global("caelestia:screenshotFreezeClip"))
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd("caelestia record -s"))
hl.bind(mainMod .. " + CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record"))
hl.bind(mainMod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + code:201", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"))
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd(apps.scripts .. "/refresh-rate.sh"))
hl.bind(mainMod .. " + CTRL + SHIFT + M", hl.dsp.exec_cmd(apps.scripts .. "/gpu-switch.sh"))

-- Windows Management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Layout Management (Floating)
hl.bind(
    mainMod .. " + SHIFT + F",
    hl.dsp.exec_cmd(
        'hyprctl --batch "dispatch togglefloating; dispatch resizeactive exact 1000 600; dispatch centerwindow"'
    )
)
hl.bind(mainMod .. " + ALT + F", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))

-- Window Focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll Workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse Window Drag/Resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media & Brightness (Repeating / Locked)
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true }
)

hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
