local save_dir = "$HOME/Videos/recordings"
local fps = 60
local out_file = save_dir .. "/recording_$(date +%Y%m%d_%H%M%S).mp4"

local gsr_audio_sys = "-a default_output"
local gsr_audio_mix = '-a "default_output|default_input"'
local gsr_base = string.format("gpu-screen-recorder -f %d -k h264 -ac opus", fps)

local ghost_slurp = "nix run nixpkgs#slurp -- -f '%wx%h+%x+%y'"

return {
	mon_mic = string.format(
		"sh -c 'mkdir -p %s && %s -w screen %s -o %s'",
		save_dir,
		gsr_base,
		gsr_audio_mix,
		out_file
	),
	mon = string.format("sh -c 'mkdir -p %s && %s -w screen %s -o %s'", save_dir, gsr_base, gsr_audio_sys, out_file),

	region_mic = string.format(
		'sh -c \'mkdir -p %s && REGION=$(%s) && [ -n "$REGION" ] && %s -w "$REGION" %s -o %s\'',
		save_dir,
		ghost_slurp,
		gsr_base,
		gsr_audio_mix,
		out_file
	),
	region = string.format(
		'sh -c \'mkdir -p %s && REGION=$(%s) && [ -n "$REGION" ] && %s -w "$REGION" %s -o %s\'',
		save_dir,
		ghost_slurp,
		gsr_base,
		gsr_audio_sys,
		out_file
	),

	stop = "pkill -SIGINT -f gpu-screen-recorder",
}
