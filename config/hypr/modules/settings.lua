hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 10,
        border_size = 2,
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

        repeat_rate = 35,
        repeat_delay = 200,

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

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
