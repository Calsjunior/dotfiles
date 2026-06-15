local apps = require("modules.programs")
local monitors = require("modules.monitors")

-- Remove gaps when there is only 1 tiled window on screen
hl.workspace_rule({
  workspace = "w[tv1]",
  gaps_out = 0,
  gaps_in = 0,
})

-- Remove borders and rounding for that single window
hl.window_rule({
  name = "smart-gaps-border",
  match = { workspace = "w[tv1]" },
  border_size = 0,
  rounding = 0,
})

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

-- Persistence workspace
for i = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(i),
    monitor = monitors.internal.output,
    persistent = true,
  })
end
