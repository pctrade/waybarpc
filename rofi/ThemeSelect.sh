#!/usr/bin/env bash

themes_dir="$HOME/.config/waybar/themes"
cache_dir="$HOME/.config/waybar/cache/walls-cache"
rofi_command="rofi -dmenu -theme $HOME/.config/waybar/rofi/ThemeSelect.rasi"

# Verificar que el directorio de temas existe
if [ ! -d "$themes_dir" ]; then
    echo "Error: Directory '$themes_dir' does not exist"
    exit 1
fi

echo "Scanning themes and wallpapers..."

# Crear lista temporal para rofi
temp_list=""

# Recorrer cada carpeta de tema
for theme_dir in "$themes_dir"/*; do
    [ -d "$theme_dir" ] || continue
    
    theme_name=$(basename "$theme_dir")
    wallpaper_flag="$theme_dir/walls/.wallpaper"
    
    # Verificar si existe la bandera .wallpaper
    if [ -f "$wallpaper_flag" ]; then
        wallpaper_path=$(cat "$wallpaper_flag")
        wallpaper_filename=$(basename "$wallpaper_path")
        
        # Buscar en cache
        cache_file="$cache_dir/$theme_name/$wallpaper_filename"
        
        if [ -f "$cache_file" ]; then
            # Agregar a la lista de rofi con icono
            temp_list+="$theme_name\0icon\037$cache_file\n"
        else
            # Si no hay cache, agregar sin icono
            temp_list+="$theme_name\n"
        fi
    else
        # Si no hay .wallpaper, agregar tema sin icono
        temp_list+="$theme_name\n"
    fi
done

echo "Launching theme selector..."

# Lanzar rofi
selected_theme=$(printf "$temp_list" | $rofi_command)

if [ -n "$selected_theme" ]; then
    echo "Selected theme: $selected_theme"
    # Lanzar el script del tema
    "$HOME/.config/waybar/themes/theme.sh" "$selected_theme"
else
    echo "No theme selected."
fi
