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
