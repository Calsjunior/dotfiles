-- Force the terminal file chooser to float and center like a real popup dialog
hl.window_rule({
    name = "termfilechooser-dialog",
    match = { class = "^(termfilechooser)$" },
    float = true,
    size = "900 600",
    center = true,
})
