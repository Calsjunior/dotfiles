local apps = require("modules.programs")

-- Auto launch Zen into web special workspace if empty
hl.workspace_rule({
    workspace = "special:web",
    on_created_empty = apps.browser,
})

hl.window_rule({
    name = "zen-browser-special",
    match = { class = "^(zen.*)$" },
    workspace = "special:web silent",
})

-- Force the terminal file chooser to float and center like a real popup dialog
hl.window_rule({
    name = "termfilechooser-dialog",
    match = { class = "^(termfilechooser)$" },
    float = true,
    size = "900 600",
    center = true,
})

-- Auto-center floating windows on open
hl.on("window.open", function(w)
    if w.floating then
        hl.dispatch(hl.dsp.window.center())
    end
end)
