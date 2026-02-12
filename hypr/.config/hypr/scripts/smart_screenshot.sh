#!/usr/bin/env bash

color=$(jq -r '.colours.primary_paletteKeyColor' ~/.local/state/caelestia/scheme.json 2>/dev/null)

if [[ -z "$color" || "$color" == "null" ]]; then
    color="ffffff"
fi

time=$(date +%Y%m%d%H%M%S)
tmp_dir="/tmp"
save_dir="$HOME/Pictures/Screenshots"
final_file="$save_dir/$time.png"
freeze_file="$tmp_dir/freeze_temp.png"

grim "$freeze_file"

imv -f "$freeze_file" >/dev/null 2>&1 &

view_pid=$!
trap "kill $view_pid 2>/dev/null; rm -f $freeze_file" EXIT

sleep 0.1

geometry=$(slurp -b 00000040 -c "$color" -f "%wx%h+%x+%y")

if [ -z "$geometry" ]; then
    exit 1
fi

mogrify -crop "$geometry" +repage "$freeze_file"

kill $view_pid 2>/dev/null
trap - EXIT

wl-copy <"$freeze_file"
action=$(notify-send \
    --wait \
    -i "$freeze_file" \
    -a "Screenshot" \
    "Screenshot Taken" \
    "Copied to clipboard.\n" \
    --action="save=Save to Disk")

if [[ "$action" == "save" ]]; then
    mkdir -p "$save_dir"
    mv "$freeze_file" "$final_file"
    notify-send -a "Screenshot" "Saved" "Image saved to $final_file" -i "$final_file" -t 3000
else
    rm -f "$freeze_file"
fi
