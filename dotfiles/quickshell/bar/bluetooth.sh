#!/bin/bash
# /home/suvadip/myos/dotfiles/quickshell/bar/bluetooth.sh

max_len="${1:-15}"

format_output() {
    local icon="$1"
    local text="$2"
    
    if [ ${#text} -gt $max_len ]; then
        text="${text:0:$max_len}..."
    fi
    
    echo "${icon}__SEP__${text}"
}

# 1. Check if BT is powered on
powered=$(bluetoothctl show 2>/dev/null | grep "Powered: yes")

if [ -z "$powered" ]; then
    format_output "󰂲" "bt_off" # Crossed icon
    exit 0
fi

# 2. Check connected devices
device=$(bluetoothctl devices Connected 2>/dev/null | head -n 1 | cut -d' ' -f3-)

if [ -z "$device" ]; then
    # 3. On, but not connected
    format_output "󰂯" "not_connected" # Hollow icon
else
    # 4. On and connected
    format_output "󰂱" "$device" # Filled/Connected icon
fi
