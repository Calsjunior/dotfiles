local home = os.getenv("HOME")
local scripts = home .. "/.config/hypr/scripts"
local theme = require("theme")

-- ================
-- MONITOR
-- ================
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-3",
    mode = "1920x1080@165",
    position = "0x0",
    scale = 1,
    mirror = "eDP-1",
})

-- ================
-- PROGRAMS
-- ================
local terminal = "kitty -1"
local fileManager = terminal .. " yazi"
local browser = "zen-browser"
local editor = terminal .. " nvim"
local session = [[kitty -1 -e zsh -c "nvim +\"lua vim.schedule(function() vim.api.nvim_input('s') end)\""]]
local pacman = terminal .. " pacseek"
local menu = "caelestia shell drawers toggle launcher"
local power_menu = "caelestia shell drawers toggle session"
local dashboard = "caelestia shell drawers toggle dashboard"
local notif_clear = "caelestia shell notifs clear"

-- ================
-- KEYBINDS
-- ================
local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(pacman))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(session))

-- Caelestia
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(power_menu))
hl.bind(mainMod .. " + ALT + Q", hl.dsp.exec_cmd(scripts .. "/kill-process.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(dashboard))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(scripts .. "/wallpaper.sh"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd(scripts .. "/scheme.sh"))
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd(notif_clear))

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
hl.bind(mainMod .. " + SHIFT + code:201", hl.dsp.exec_cmd(scripts .. "/switch-keyboard.sh"))
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd(scripts .. "/refresh-rate.sh"))
hl.bind(mainMod .. " + CTRL + SHIFT + M", hl.dsp.exec_cmd(scripts .. "/gpu-switch.sh"))

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

-- ================
-- AUTOSTART
-- ================
hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 1 && " .. terminal .. " --start-as=hidden")

    -- Quickshell/Caelestia Shell
    hl.exec_cmd("caelestia shell -d")
    hl.exec_cmd(scripts .. "/theme-bridge.sh")

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

-- ================
-- ENVIRONTMENT VAR
-- ================
-- Inject mise path so programs launched by keybind can find path
hl.env("PATH", home .. "/.local/share/mise/shims:" .. os.getenv("PATH"))

-- Integrated GPU driver
hl.env("LIBVA_DRIVER_NAME", "iHD")

-- Force FreeType to use the Windows ClearType rendering engine
hl.env("FREETYPE_PROPERTIES", "truetype:interpreter-version=40")

-- Cursor
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")

-- Toolkit Backend Variables
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("GDK_SCALE", "1")
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")

-- XDG Specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- QT Variables
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

-- Browser & Electron
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Force GTK apps to use the XDG Portal
hl.env("GTK_USE_PORTAL", "1")

-- ================
-- SETTINGS & LOOK AND FEEL
-- ================
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = "rgb(" .. theme.primary_paletteKeyColor .. ")",
            inactive_border = "rgb(" .. theme.background .. ")",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 14,
        rounding_power = 4,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },

    input = {
        kb_layout = "us,kh",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:escape",
        kb_rules = "",

        follow_mouse = 1,
        sensitivity = 0.5,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            scroll_factor = 0.2,
            clickfinger_behavior = false,
            middle_button_emulation = true,
            tap_to_click = true,
            drag_lock = false,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ================
-- ANIMATIONS
-- ================
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- ================
-- ANIMATIONS
-- ================

-- Force the terminal file chooser to float and center like a real popup dialog
hl.window_rule({
    name = "termfilechooser-dialog",
    match = { class = "^(termfilechooser)$" },
    float = true,
    size = "900 600",
    center = true,
})
