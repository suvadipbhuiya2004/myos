
#!/bin/bash
# /home/suvadip/myos/dotfiles/quickshell/bar/network.sh

max_len="${1:-15}"

# Helper function to truncate text and print it with the icon
format_output() {
    local icon="$1"
    local text="$2"
    
    # Apply max length rule to ALL text
    if [ ${#text} -gt $max_len ]; then
        text="${text:0:$max_len}..."
    fi
    
    # Output format: ICON__SEP__TEXT
    echo "${icon}__SEP__${text}"
}

# 1. Check for active Ethernet connection first (takes priority)
# Using head -n 1 just in case you have multiple wired interfaces
eth_conn=$(nmcli -t -f STATE,TYPE,CONNECTION dev 2>/dev/null | grep '^connected:ethernet:' | head -n 1 | cut -d: -f3)

if [ -n "$eth_conn" ]; then
    format_output "󰈀" "$eth_conn" # Ethernet icon
    exit 0
fi

# 2. Check if Wi-Fi radio is disabled
wifi_state=$(nmcli -t -f WIFI general 2>/dev/null)
if [ "$wifi_state" = "disabled" ] || [ -z "$wifi_state" ]; then
    format_output "󰤭" "wifi_off" # Crossed icon
    exit 0
fi

# 3. Check for active Wi-Fi connection
ssid=$(nmcli -t -f STATE,TYPE,CONNECTION dev 2>/dev/null | grep '^connected:wifi:' | head -n 1 | cut -d: -f3)

if [ -z "$ssid" ]; then
    # 4. On, but not connected
    format_output "󰤯" "not_connected" # Hollow icon
else
    # 5. On and connected
    format_output "󰤨" "$ssid" # Filled icon
fi
