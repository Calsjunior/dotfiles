local function create_spring(name, mass, stiffness, ratio)
  local dampening = ratio * 2 * math.sqrt(mass * stiffness)
  hl.curve(name, { type = "spring", mass = mass, stiffness = stiffness, dampening = dampening })
end

create_spring("niri_spring", 1, 800, 1.0)
create_spring("niri_snappy", 1, 1000, 1.0)

-- Global Animation Flag
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })

-- Windows & Layers
hl.animation({ leaf = "windows", enabled = true, speed = 10, spring = "niri_snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 10, spring = "niri_snappy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 10, spring = "niri_snappy", style = "popin 80%" })
hl.animation({ leaf = "layers", enabled = true, speed = 10, spring = "niri_snappy", style = "fade" })

-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 10, spring = "niri_spring", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 10, spring = "niri_snappy", style = "fade" })

-- Standard Fades
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "default" })
