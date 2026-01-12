#!/bin/bash

# --- Paths ---
HYPR_DIR="$HOME/.config/hypr/themes"
DUNST_DIR="$HOME/.config/dunst"
WALLPAPER_BASE="$HOME/Pictures"

# --- Theme Selection Menu ---
# We use Rofi to display the list of themes
choice=$(echo -e "Monochrome\nCappuccino\nNerd" | rofi -dmenu -p "Select Theme:" -config ~/.config/rofi/config.rasi)

# Exit if no theme was selected (e.g., pressed Esc)
if [ -z "$choice" ]; then
    exit 0
fi

# Convert theme name to lowercase for file paths
theme=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

# --- 1. Update Hyprland Theme ---
# Copy the selected theme config to the active 'current.conf'
if [ -f "$HYPR_DIR/$theme.conf" ]; then
    cp "$HYPR_DIR/$theme.conf" "$HYPR_DIR/current.conf"
else
    notify-send -u critical "Error" "Hyprland theme file not found: $theme.conf"
fi

# --- 2. Update Dunst Config ---
# Merge base settings with theme-specific colors
if [ -f "$DUNST_DIR/themes/$theme.conf" ]; then
    cat "$DUNST_DIR/dunstrc_base" "$DUNST_DIR/themes/$theme.conf" > "$DUNST_DIR/dunstrc"
    # Restart Dunst to apply changes
    killall dunst
    dunst &
else
    notify-send -u critical "Error" "Dunst theme file not found: $theme.conf"
fi

# --- 3. Set Random Wallpaper ---
# Path to the folder: e.g., ~/Pictures/nerd/
WALL_DIR="$WALLPAPER_BASE/$theme"

if [ -d "$WALL_DIR" ]; then
    # Find all jpg, jpeg, and png files, then pick one at random
    RANDOM_WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

    if [ -n "$RANDOM_WALL" ]; then
        # Using swww to set the wallpaper with a nice transition
        swww img "$RANDOM_WALL" --transition-type grow --transition-fps 60 --transition-duration 1.5
    else
        notify-send -u low "Warning" "No wallpapers found in $WALL_DIR"
    fi
else
    notify-send -u low "Warning" "Wallpaper directory not found: $WALL_DIR"
fi

# --- 4. Final Notification ---
notify-send -u normal "Theme Applied" "System style set to: $choice"
