#!/usr/bin/env bash

#usage theme.sh Gruvbox >> will apply Gruvbox theme 

THEME=$1
THEME_DIR="$HOME/.config/waybar/themes"
COLORS_FILE="$HOME/.config/waybar/colors.css"
COLORS_ROFI_FILE="$HOME/.config/waybar/rofi/shared.rasi"

if [ -z "$THEME" ]; then
    echo "Uso: $0 <nombre_tema>"
    echo "Temas disponibles: Catppuccin Dracula Everforest Gruvbox Kanagawa Nord OneDark Oxocarbon Rosepine Tokyo"
    exit 1
fi

# Funtion to apply themes and colors with arrays
setup_theme() {
    local colors=("$@")
    local accent_color="$(cat ~/.config/waybar/themes/$THEME/.accent)"
    local accent2_color="$(cat ~/.config/waybar/themes/$THEME/.accent2)"

    cat > "$COLORS_ROFI_FILE" << EOF
* {
    font: "CaskaydiaCove NF 12";
    background: ${colors[0]};
    bg-alt: ${colors[1]};
    background-alt: ${colors[2]};
    foreground: ${colors[6]};
    selected: $accent_color;
    active: ${colors[9]};
    urgent: ${colors[10]};
}
EOF

    cat > "$COLORS_FILE" << EOF
@define-color bg ${colors[0]};
@define-color bg-alt ${colors[1]};
@define-color bg-alt2 ${colors[2]};
@define-color bg-alt3 ${colors[3]};
@define-color border ${colors[4]};
@define-color border2 ${colors[5]};
@define-color text ${colors[6]};
@define-color tex-dark ${colors[7]};
@define-color accent $accent_color;
@define-color accent2 $accent2_color;
@define-color red ${colors[10]};
EOF
    kitty +kitten themes --reload-in=all "${colors[11]}"
    #gsettings set org.gnome.desktop.interface gtk-theme "${colors[12]}"
    #gsettings set org.gnome.desktop.interface icon-theme "${colors[13]}"
    echo "$accent_color" > $HOME/.config/waybar/themes/$THEME/.accent
    echo "$accent2_color" > $HOME/.config/waybar/themes/$THEME/.accent2
    ~/.config/waybar/icons/fill.sh $accent_color
    ~/.config/waybar/icons/weather/fill.sh ${colors[6]}
    ~/.config/waybar/icons/system/fill.sh $accent2_color
    wallpaper_file="$THEME_DIR/$THEME/walls/.wallpaper"
    echo "Debug: Looking for wallpaper file at: $wallpaper_file"

    if [ -f "$wallpaper_file" ]; then
        wallpaper=$(cat "$wallpaper_file")
        echo "Debug: Found wallpaper path: $wallpaper"
    else
        wallpaper="$HOME/.config/eww/themes/default.jpg"
        echo "Debug: Using default wallpaper: $wallpaper"
    fi

    if [ -f "$wallpaper" ]; then
        echo "Debug: Changing wallpaper to: $wallpaper with transition: $transition"
        swww img "$wallpaper" --transition-type any --transition-fps 60 --transition-duration 0.4
        echo "$wallpaper" > $HOME/.config/waybar/cache/.wallpaper
    else
        echo "Error: Wallpaper file not found: $wallpaper"
    fi
}

case "$THEME" in
    "Catppuccin")
        setup_theme "#1e1e2e" "#11111b" "#181825" "#313244" "#585b70" "#45475a" "#cdd6f4" "#181825" "#b4befe" "#cba6f7" "#f38ba8" "Catppuccin-Mocha" #"your-gtk-theme" "your-icon-theme"
        ;;
    "Gruvbox")
        setup_theme "#282828" "#1d2021" "#32302f" "#3c3836" "#504945" "#665c54" "#ebdbb2" "#282828" "#98971a" "#fe8019" "#cc241d" "Gruvbox Dark"
        ;;
    "Nord")
        setup_theme "#2e3440" "#3b4252" "#434c5e" "#4c566a" "#5e81ac" "#81a1c1" "#eceff4" "#2e3440" "#81A1C1" "#8FBCBB" "#bf616a" "Nord"
        ;;
    "Dracula")
        setup_theme "#282a36" "#21222c" "#44475a" "#44475A" "#44475a" "#ff79c6" "#f8f8f2" "#282a36" "#bd93f9" "#50FA7B" "#ff5555" "Dracula"
        ;;
    "Tokyo")
        setup_theme "#1a1b26" "#16161e" "#24283b" "#414868" "#565f89" "#6183bb" "#c0caf5" "#1a1b26" "#7aa2f7" "#bb9af7" "#f7768e" "Tokyo Night"
        ;;
    "Everforest")
        setup_theme "#2d353b" "#232a2e" "#343f44" "#3d484d" "#495156" "#d3c6aa" "#d3c6aa" "#2d353b" "#a7c080" "#83c092" "#e67e80" "Everforest Dark Hard"
        ;;
    "Rosepine")
        setup_theme "#191724" "#1f1d2e" "#26233a" "#403d52" "#524f67" "#6e6a86" "#e0def4" "#191724" "#c4a7e7" "#ebbcba" "#eb6f92" "Rosé Pine"
        ;;
    "Onedark")
        setup_theme "#282c34" "#21252b" "#2c313c" "#3e4451" "#4b5263" "#5c6370" "#abb2bf" "#282c34" "#61afef" "#c678dd" "#e06c75" "One Dark"
        ;;
    "Oxocarbon")
        setup_theme "#161616" "#0f1419" "#262626" "#393939" "#525252" "#6f6f6f" "#f2f4f8" "#161616" "#78a9ff" "#be95ff" "#ff7eb6" "Carbonfox"
        ;;
    "Kanagawa")
        setup_theme "#1f1f28" "#16161d" "#2a2a37" "#363646" "#54546d" "#727169" "#dcd7ba" "#1f1f28" "#7e9cd8" "#957fb8" "#e82424" "Kanagawa"
        ;;
esac

echo "$THEME" > $THEME_DIR/.theme
pkill waybar && waybar &
