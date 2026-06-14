local monitors = {
	internal = {
		output = "eDP-1",
		mode = "1920x1080@60",
		position = "0x0",
		scale = "1",
	},
	external1 = {
		output = "DP-3",
		mode = "1920x1080@165",
		position = "0x0",
		scale = "1",
	},
	external2 = {
		output = "DP-1",
		mode = "1920x1080@165",
		position = "0x0",
		scale = "1",
	},
}

for _, m in pairs(monitors) do
	hl.monitor(m)
end

return monitors
