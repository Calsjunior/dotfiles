#!/usr/bin/env bash

monitor_info=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')

name=$(echo "$monitor_info" | jq -r '.name')
width=$(echo "$monitor_info" | jq -r '.width')
height=$(echo "$monitor_info" | jq -r '.height')
scale=$(echo "$monitor_info" | jq -r '.scale')
x_pos=$(echo "$monitor_info" | jq -r '.x')
y_pos=$(echo "$monitor_info" | jq -r '.y')
current_rate=$(echo "$monitor_info" | jq -r '.refreshRate')

current_rate_int=$(printf "%.0f" "$current_rate")

rates=$(echo "$monitor_info" | jq -r '.availableModes[]' | grep "${width}x${height}" | cut -d '@' -f2 | sed 's/Hz//' | sort -rn)

max_rate=$(echo "$rates" | head -n 1)
min_rate=$(echo "$rates" | tail -n 1)

max_rate_int=$(printf "%.0f" "$max_rate")
min_rate_int=$(printf "%.0f" "$min_rate")

if [[ "$current_rate_int" -ge "$max_rate_int" ]]; then
    target_rate=$min_rate
else
    target_rate=$max_rate
fi

hyprctl keyword monitor "$name,${width}x${height}@${target_rate},${x_pos}x${y_pos},$scale"

notify-send "Refresh Rate" "Set to ${target_rate}Hz"
