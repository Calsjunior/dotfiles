local apps = require("modules.programs")
local monitor_utils = require("modules.monitor_utils")
local main_mod = "SUPER"
local ipc = apps.ipc

-- Applications
hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(apps.terminal))
hl.bind(main_mod .. " + C", hl.dsp.exec_cmd(apps.editor))
hl.bind(main_mod .. " + B", hl.dsp.workspace.toggle_special("web"))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(apps.fileManager))
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd(apps.session))

-- Noctalia v5
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(main_mod .. " + N", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(main_mod .. " + SHIFT + B", hl.dsp.exec_cmd(ipc .. " settings-toggle"))
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.exec_cmd(ipc .. " panel-toggle session"))
hl.bind(main_mod .. " + CTRL + N", hl.dsp.exec_cmd(ipc .. " notification-clear-active"))

-- Clipboard
hl.bind(main_mod .. " + CTRL + V", hl.dsp.exec_cmd(ipc .. " panel-toggle clipboard"))

-- Screenshots
hl.bind(main_mod .. " + PRINT", hl.dsp.exec_cmd(ipc .. " screenshot-region"))
hl.bind(main_mod .. " + SHIFT + PRINT", hl.dsp.exec_cmd(ipc .. " screenshot-fullscreen"))

-- Record
-- hl.bind(main_mod .. " + ALT + R", hl.dsp.exec_cmd("caelestia record -s"))
-- hl.bind(main_mod .. " + CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record"))
-- hl.bind(main_mod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r"))

-- Utility Scripts
hl.bind(main_mod .. " + W", hl.dsp.exec_cmd(apps.scripts .. "/wallpaper.sh"))
hl.bind(main_mod .. " + CTRL + W", hl.dsp.exec_cmd(apps.scripts .. "/scheme.sh"))
hl.bind(main_mod .. " + CTRL + SHIFT + M", hl.dsp.exec_cmd(apps.scripts .. "/gpu-switch.sh"))
hl.bind(main_mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(main_mod .. " + SHIFT + code:201", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"))
hl.bind(main_mod .. " + F2", monitor_utils.toggle_refresh_rate)

-- Window Management
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + ALT + Q", function()
    local w = hl.get_active_window()
    if w ~= nil then
        os.execute("kill " .. w.pid)
    end
end)
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(main_mod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(main_mod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(main_mod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Floating
hl.bind(main_mod .. " + SHIFT + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 1000, y = 600 }))
    hl.dispatch(hl.dsp.window.center())
end)

-- Window Focus
hl.bind(main_mod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(main_mod .. " + j", hl.dsp.focus({ direction = "d" }))
hl.bind(main_mod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(main_mod .. " + l", hl.dsp.focus({ direction = "r" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspace
hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll Workspaces
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media & Brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"), { locked = true, repeating = true })
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. " media next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. " media toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. " media toggle"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. " media previous"), { locked = true })
