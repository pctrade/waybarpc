#!/usr/bin/env bash

SYMBOLS_FILE="$HOME/.config/waybar/rofi/nerdfont-icons-fixed.txt"

SELECTED=$(cat "$SYMBOLS_FILE" | rofi -dmenu -i -theme $HOME/.config/waybar/rofi/icons.rasi)

CHAR=$(echo "$SELECTED" | awk '{print $1}')

if [ -n "$CHAR" ]; then
  echo -n "$CHAR" | wl-copy
fi
