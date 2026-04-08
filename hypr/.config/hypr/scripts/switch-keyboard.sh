#!/usr/bin/env bash

device=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name')
hyprctl switchxkblayout "$device" next
