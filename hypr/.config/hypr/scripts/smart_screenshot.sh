#!/usr/bin/env bash

color=$(jq -r '.colours.primary_paletteKeyColor' ~/.local/state/caelestia/scheme.json 2>/dev/null)

if [[ -z "$color" || "$color" == "null" ]]; then
    color="ffffff"
fi

time=$(date +%Y%m%d%H%M%S)
tmp_dir="/tmp"
save_dir="$HOME/Pictures/Screenshots"
file="$tmp_dir/Temp-$time.png"
final_file="$save_dir/$time.png"

geometry=$(slurp -b 00000040 -c "$color")

if [ -z "$geometry" ]; then
    exit 1
fi

sleep 0.2

grim -g "$geometry" "$file"
wl-copy <"$file"
action=$(notify-send \
    -i "$file" \
    -a "Screenshot" \
    "Screenshot Taken" \
    "Copied to clipboard.\n" \
    --action="save=Save to Disk")

if [[ "$action" == "save" ]]; then
    mkdir -p "$save_dir"
    mv "$file" "$final_file"
    notify-send -a "Screenshot" "Saved" "Image saved to $final_file" -i "$final_file" -t 3000
fi
