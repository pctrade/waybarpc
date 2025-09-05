#!/usr/bin/env bash
# =============================================================
# Dependencies:
#   → Wayland: swww, rofi (wayland), xxhsum, imagemagick
#   → X11: feh, rofi, xxhsum, imagemagick
#   → GNU: findutils, coreutils
# =============================================================

THEME=$(cat ~/.config/waybar/themes/.theme)
wall_dir="$HOME/.config/waybar/themes/$THEME/walls"
cacheDir="$HOME/.config/waybar/cache/walls-cache/$THEME"

# Validate wallpaper directory
if [ ! -d "$wall_dir" ]; then
    echo "Error: Directory '$wall_dir' does not exist"
    exit 1
fi

# Create cache dir if not exists
[ -d "$cacheDir" ] || mkdir -p "$cacheDir"

# Detect session type and set appropriate commands
detect_session() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo "wayland"
    elif [ -n "$DISPLAY" ]; then
        echo "x11"
    else
        # Fallback detection
        if pgrep -x "sway\|Hyprland\|river\|wayfire" >/dev/null 2>&1; then
            echo "wayland"
        elif pgrep -x "Xorg\|X" >/dev/null 2>&1; then
            echo "x11"
        else
            echo "unknown"
        fi
    fi
}

SESSION_TYPE=$(detect_session)

# Set commands based on session type
case "$SESSION_TYPE" in
    "wayland")
        rofi_command="rofi -dmenu -theme $HOME/.config/waybar/rofi/WallSelect.rasi"
        set_wallpaper() {
            if command -v swww >/dev/null 2>&1; then
                # Check if swww daemon is running
                if ! pgrep -x swww-daemon >/dev/null 2>&1; then
                    swww-daemon &
                    sleep 2
                fi
                swww img "$1" --transition-type any --transition-fps 60 --transition-duration 0.4
            else
                echo "Error: swww not found. Install it for Wayland wallpaper support."
                exit 1
            fi
        }
        ;;
    "x11")
        rofi_command="rofi -dmenu -theme $HOME/.config/waybar/rofi/WallSelect.rasi"
        set_wallpaper() {
            if command -v feh >/dev/null 2>&1; then
                feh --no-fehbg --bg-fill "$1"
            else
                echo "Error: feh not found. Install it for X11 wallpaper support."
                exit 1
            fi
        }
        ;;
    *)
        echo "Error: Unable to detect session type (Wayland/X11)"
        echo "Make sure you're running this script in a graphical session"
        exit 1
        ;;
esac

echo "Detected session: $SESSION_TYPE"

# Detect number of cores and set a sensible number of jobs
get_optimal_jobs() {
    cores=$(nproc)
    if [ "$cores" -le 2 ]; then
        echo 2
    elif [ "$cores" -gt 4 ]; then
        echo 4
    else
        echo $((cores - 1))
    fi
}

PARALLEL_JOBS=$(get_optimal_jobs)

# Image processing function
process_func_def='process_image() {
    imagen="$1"
    nombre_archivo=$(basename "$imagen")
    cache_file="${cacheDir}/${nombre_archivo}"
    md5_file="${cacheDir}/.${nombre_archivo}.md5"
    lock_file="${cacheDir}/.lock_${nombre_archivo}"

    current_md5=$(xxh64sum "$imagen" | cut -d " " -f1)

    (
        flock -x 9
        if [ ! -f "$cache_file" ] || [ ! -f "$md5_file" ] || [ "$current_md5" != "$(cat "$md5_file" 2>/dev/null)" ]; then
            magick "$imagen" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"
            echo "$current_md5" > "$md5_file"
        fi
        rm -f "$lock_file"
    ) 9>"$lock_file"
}'

export process_func_def cacheDir wall_dir

# Clean old locks before starting
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

echo "Processing wallpapers in parallel..."

# Process files in parallel
find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | \
    xargs -0 -P "$PARALLEL_JOBS" -I {} sh -c "$process_func_def; process_image \"{}\""

# Clean orphaned cache files and their locks
for cached in "$cacheDir"/*; do
    [ -f "$cached" ] || continue
    original="${wall_dir}/$(basename "$cached")"
    if [ ! -f "$original" ]; then
        nombre_archivo=$(basename "$cached")
        rm -f "$cached" \
            "${cacheDir}/.${nombre_archivo}.md5" \
            "${cacheDir}/.lock_${nombre_archivo}"
    fi
done

# Clean any remaining lock files
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

echo "Launching wallpaper selector..."

# Launch rofi
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 |
    xargs -0 basename -a |
    LC_ALL=C sort |
    while IFS= read -r A; do
        printf '%s\000icon\037%s/%s\n' "$A" "$cacheDir" "$A"
    done | $rofi_command)

# Set wallpaper if selection was made
if [ -n "$wall_selection" ]; then
    selected_wallpaper="${wall_dir}/${wall_selection}"
    echo "$selected_wallpaper" > "$wall_dir/.wallpaper"
    echo "Setting wallpaper: $selected_wallpaper"
    set_wallpaper "$selected_wallpaper"
    echo "Wallpaper applied successfully!"
else
    echo "No wallpaper selected."
fi
