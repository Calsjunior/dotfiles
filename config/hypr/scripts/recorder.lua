local save_dir = "$HOME/Videos/recordings"
local fps = 60
local out_file = save_dir .. "/recording_$(date +%Y%m%d_%H%M%S).mp4"

local gsr_audio_sys = "-a default_output"
local gsr_audio_mix = '-a "default_output|default_input"'
local gsr_base = string.format("gpu-screen-recorder -f %d -k h264 -ac opus", fps)

local ghost_slurp = "nix run nixpkgs#slurp -- -f '%wx%h+%x+%y'"
local ghost_notify = "nix run nixpkgs#libnotify --"

local function record(source, audio)
  return string.format(
    'sh -c \'mkdir -p %s && FILE=%s && %s -w %s %s -o "$FILE" && %s "Recording Saved" "$FILE"\'',
    save_dir,
    out_file,
    gsr_base,
    source,
    audio,
    ghost_notify
  )
end

return {
  mon_mic = record("screen", gsr_audio_mix),
  mon = record("screen", gsr_audio_sys),
  region_mic = string.format(
    'sh -c \'mkdir -p %s && REGION=$(%s) && [ -n "$REGION" ] && FILE=%s && %s -w region -region "$REGION" %s -o "$FILE" && %s "Recording Saved" "$FILE"\'',
    save_dir,
    ghost_slurp,
    out_file,
    gsr_base,
    gsr_audio_mix,
    ghost_notify
  ),
  region = string.format(
    'sh -c \'mkdir -p %s && REGION=$(%s) && [ -n "$REGION" ] && FILE=%s && %s -w region -region "$REGION" %s -o "$FILE" && %s "Recording Saved" "$FILE"\'',
    save_dir,
    ghost_slurp,
    out_file,
    gsr_base,
    gsr_audio_sys,
    ghost_notify
  ),
  stop = "pkill -SIGINT -f gpu-screen-recorder",
}
