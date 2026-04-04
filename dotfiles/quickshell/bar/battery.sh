#!/bin/bash
# /home/suvadip/myos/dotfiles/quickshell/bar/battery.sh

# 1. Fetch battery info using upower
# We'll target the first battery device found
bat_path=$(upower -e | grep battery | head -n 1)

if [ -z "$bat_path" ]; then
    echo "󰂎__SEP__No Bat"
    exit 0
fi

# Extract percentage and state
info=$(upower -i "$bat_path")
percentage=$(echo "$info" | grep "percentage" | awk '{print $2}' | tr -d '%')
state=$(echo "$info" | grep "state" | awk '{print $2}')

# 2. Determine icon based on state and percentage
icon="󰁹" # Default: Full battery

if [ "$state" = "charging" ] || [ "$state" = "fully-charged" ]; then
    icon="󰂄" # Charging icon
else
    # Discharging: Use percentage-based icons
    if [ "$percentage" -le 10 ]; then
        icon="󰁺"
    elif [ "$percentage" -le 20 ]; then
        icon="󰁻"
    elif [ "$percentage" -le 30 ]; then
        icon="󰁼"
    elif [ "$percentage" -le 40 ]; then
        icon="󰁽"
    elif [ "$percentage" -le 50 ]; then
        icon="󰁾"
    elif [ "$percentage" -le 60 ]; then
        icon="󰁿"
    elif [ "$percentage" -le 70 ]; then
        icon="󰂀"
    elif [ "$percentage" -le 80 ]; then
        icon="󰂁"
    elif [ "$percentage" -le 90 ]; then
        icon="󰂂"
    else
        icon="󰁹"
    fi
fi

# Output format: ICON__SEP__PERCENTAGE%
echo "${icon}__SEP__${percentage}%"
