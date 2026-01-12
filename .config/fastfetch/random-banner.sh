#!/bin/bash

LOGO_DIR="$HOME/.config/fastfetch/logos"
TARGET="$LOGO_DIR/current"
mkdir -p "$LOGO_DIR"

logos=("$LOGO_DIR"/*.txt)

if [ ${#logos[@]} -eq 0 ] || [ "${logos[0]}" = "$LOGO_DIR/*.txt" ]; then
    echo "No logos found in $LOGO_DIR"
    exit 1
fi

# Pick random logo
random_logo=${logos[$RANDOM % ${#logos[@]}]}

# Remove old symlink if exists
[ -L "$TARGET" ] && rm "$TARGET"

# Create new symlink
ln -s "$random_logo" "$TARGET"
echo "Symlinked $(basename "$random_logo") to $TARGET"
