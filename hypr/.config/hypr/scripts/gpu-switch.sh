#!/usr/bin/env bash

current=$(envycontrol --query)

if [[ "$current" == *"integrated"* ]]; then
    pkexec envycontrol --switch hybrid &&
        notify-send "GPU Mode" "Switched to Hybrid — reboot to apply"
else
    pkexec envycontrol --switch integrated &&
        notify-send "GPU Mode" "Switched to Integrated — reboot to apply"
fi
