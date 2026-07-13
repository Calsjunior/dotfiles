local save_dir = "$HOME/Videos/recordings"
local fps = 60
local out_file = save_dir .. "/recording_$(date +%Y%m%d_%H%M%S).mp4"

local msg_start = "Starting Recording"
local msg_saved = "Recording Saved"
local notify_time_ms = 1000
local pre_record_delay = 1.4

local gsr_base = string.format("gpu-screen-recorder -f %d -k h264 -ac opus -cr full", fps)

local ghost_slurp = "nix run nixpkgs#slurp -- -f '%wx%h+%x+%y'"
local ghost_notify = "nix run nixpkgs#libnotify --"

local function record(is_region, req_mic)
  local slurp_cmd = ""
  local source = "screen"

  if is_region then
    slurp_cmd = string.format('REGION=$(%s) && [ -n "$REGION" ] && ', ghost_slurp)
    source = '"$REGION"'
  end

  local gsr_sys = string.format('%s -w %s -a default_output -o "$FILE"', gsr_base, source)
  local gsr_mix = string.format('%s -w %s -a "default_output|default_input" -o "$FILE"', gsr_base, source)

  local execute_gsr = gsr_sys
  local trap_and_dummy = ""

  if req_mic then
    trap_and_dummy =
      'DUMMY_PID=""; trap "kill \\$DUMMY_PID 2>/dev/null" EXIT; if ! wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then pw-record /dev/null & DUMMY_PID=$!; fi && '

    execute_gsr = string.format(
      "if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then %s; else %s; fi",
      gsr_sys,
      gsr_mix
    )
  end

  local setup_cmd = string.format('mkdir -p "%s" && ', save_dir) .. slurp_cmd

  return string.format(
    'sh -c \'%s%sFILE="%s" && %s -t %d "%s" "$(basename "$FILE")" && sleep %.1f && %s ; %s "%s" "$FILE" && echo -n "file://$FILE" | wl-copy -t text/uri-list\'',
    trap_and_dummy,
    setup_cmd,
    out_file,
    ghost_notify,
    notify_time_ms,
    msg_start,
    pre_record_delay,
    execute_gsr,
    ghost_notify,
    msg_saved
  )
end

return {
  mon_mic = record(false, true),
  mon = record(false, false),
  region_mic = record(true, true),
  region = record(true, false),
  stop = "pkill -SIGINT -f gpu-screen-recorder",
}
