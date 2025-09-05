#!/bin/bash

ICON_DIR="$HOME/.config/waybar/icons"
NEW_COLOR="$1"

if [[ -z "$NEW_COLOR" ]]; then
    echo "Uso: $0 <color_hex>"
    echo "Ejemplo: $0 #b4befe"
    exit 1
fi

for file in "$ICON_DIR"/*.svg; do
    [[ -e "$file" ]] || continue

    # Cambiar fill="..." excepto fill="none"
    sed -i -E "s/fill=\"(none)\"/__KEEP__NONE__/g" "$file"
    sed -i -E "s/fill=\"[^\"]+\"/fill=\"$NEW_COLOR\"/g" "$file"
    sed -i -E "s/__KEEP__NONE__/fill=\"none\"/g" "$file"

    echo "Actualizado: $file"
done
