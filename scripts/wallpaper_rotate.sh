#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper"
pgrep -x awww-daemon > /dev/null || awww-daemon &

mapfile -t IMAGES < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

# Check if we found anything at the start
if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "No images found. Exiting."
    exit 1
fi

while true; do
    # Pick randomly from the existing list in memory
    RANDOM_IMG="${IMAGES[RANDOM % ${#IMAGES[@]}]}"

    cp "$RANDOM_IMG" /tmp/wallpaper.jpg
    
    awww img "$RANDOM_IMG" --transition-type outer --transition-fps 120
    
    sleep 300
done
