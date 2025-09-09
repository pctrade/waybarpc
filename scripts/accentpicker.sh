#!/usr/bin/env bash

# Verify flag
case "$1" in
    --accent)
        ACCENT_FILE=".accent"
        ;;
    --accent2)
        ACCENT_FILE=".accent2"
        ;;
    *)
        echo "Uso: $0 [--accent|--accent2]"
        exit 1
        ;;
esac

# Read current theme
THEME=$(cat ~/.config/waybar/themes/.theme)

# Loop to ensure colors with hyprpicker somtimes hyprpicker dont have a good output
while true; do
    echo "Selecciona un color con hyprpicker..."
    COLOR=$(hyprpicker 2>/dev/null | grep '^#' | head -n1)

    if [ -n "$COLOR" ] && [[ "$COLOR" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        echo "Color seleccionado: $COLOR"
        break
    else
        echo "Error al obtener color, intentando de nuevo..."
        sleep 1
    fi
done

# Save the color flag
echo "$COLOR" > ~/.config/waybar/themes/$THEME/$ACCENT_FILE

# Reload Theme
~/.config/waybar/themes/theme.sh "$THEME"
