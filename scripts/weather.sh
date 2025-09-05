#!/usr/bin/env bash

CACHE_DIR="$HOME/.config/waybar/cache"
CACHE_FILE="$CACHE_DIR/weather-data.json"
ICONS_DIR="$HOME/.config/waybar/icons/weather"

mkdir -p "$CACHE_DIR" "$ICONS_DIR"

get_city() {
    curl -s "https://ipapi.co/city/" 2>/dev/null || echo "Machala"
}

fetch_weather() {
    local city=$(get_city)
    local url="https://v2.wttr.in/${city}?format=j1"

    local weather_data=$(curl -s "$url" --connect-timeout 10 2>/dev/null)

    if [[ $? -eq 0 && -n "$weather_data" ]]; then
        echo "{\"timestamp\": $(date +%s), \"data\": $weather_data}" > "$CACHE_FILE"
        echo "$weather_data"
    else
        load_cache
    fi
}

load_cache() {
    if [[ -f "$CACHE_FILE" ]]; then
        jq -r '.data' "$CACHE_FILE" 2>/dev/null
    fi
}

get_weather_icon() {
    local weather_code="$1"
    local hour=$(date +%H)
    local is_night=$([[ $hour -lt 6 || $hour -gt 20 ]] && echo true || echo false)

    case "$weather_code" in
        "113") echo $($is_night && echo "Moon-symbolic" || echo "Sun-symbolic") ;;
        "116") echo $($is_night && echo "CloudyMoon-symbolic" || echo "CloudSun-symbolic") ;;
        "119") echo "Clouds-symbolic" ;;
        "122") echo "Cloud-symbolic" ;;
        "143"|"248"|"260") echo "Fog-symbolic" ;;
        "176"|"263"|"266"|"293"|"296"|"299"|"302"|"305"|"353"|"356"|"359") echo "CloudRain-symbolic" ;;
        "179"|"227"|"230"|"320"|"323"|"326"|"329"|"332"|"338"|"368"|"371"|"395") echo "CloudSnowfall-symbolic" ;;
        "182"|"185"|"281"|"284"|"311"|"314"|"317"|"350"|"362"|"365"|"374"|"377") echo "CloudWaterdrop-symbolic" ;;
        "200"|"389"|"392") echo "CloudBolt-symbolic" ;;
        "308") echo "CloudStorm-symbolic" ;;
        "335") echo "CloudSnowfallMinimalistic-symbolic" ;;
        "386") echo "CloudBoltMinimalistic-symbolic" ;;
        *) echo "Cloud-symbolic" ;;
    esac
}

main() {
    local action="${1:-show}"

    case "$action" in
        "fetch")
            fetch_weather >/dev/null
            ;;
        "show"|*)
            local weather_data

            if [[ -f "$CACHE_FILE" ]]; then
                local cache_time=$(jq -r '.timestamp' "$CACHE_FILE" 2>/dev/null)
                local current_time=$(date +%s)
                local age=$((current_time - cache_time))

                if [[ $age -gt 900 ]]; then
                    weather_data=$(fetch_weather)
                else
                    weather_data=$(load_cache)
                fi
            else
                weather_data=$(fetch_weather)
            fi

            if [[ -n "$weather_data" ]]; then
                local temp=$(echo "$weather_data" | jq -r '.current_condition[0].temp_C' 2>/dev/null)
                local weather_code=$(echo "$weather_data" | jq -r '.current_condition[0].weatherCode' 2>/dev/null)
                local condition=$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value' 2>/dev/null)

                if [[ "$temp" != "null" && "$weather_code" != "null" ]]; then
                    local hour=$(date +%H)
                    local is_night=$([[ $hour -lt 6 || $hour -gt 20 ]] && echo true || echo false)

                    local weather_class
                    case "$weather_code" in
                        "113") weather_class=$($is_night && echo "night" || echo "sunny") ;;
                        "116") weather_class=$($is_night && echo "cloudy-night" || echo "cloudy-day") ;;
                        "119") weather_class="clouds" ;;
                        "122") weather_class="cloudy" ;;
                        "143"|"248"|"260") weather_class="fog" ;;
                        "176") weather_class="light-rain" ;;
                        "179") weather_class="light-snow" ;;
                        "182"|"185") weather_class="sleet" ;;
                        "200") weather_class="thunder" ;;
                        "227") weather_class="blizzard" ;;
                        "230") weather_class="heavy-snow" ;;
                        "263"|"266") weather_class="drizzle" ;;
                        "281"|"284") weather_class="freezing-drizzle" ;;
                        "293"|"296") weather_class="light-rain" ;;
                        "299"|"302") weather_class="rain" ;;
                        "305") weather_class="heavy-rain" ;;
                        "308") weather_class="storm" ;;
                        "311"|"314"|"317") weather_class="freezing-rain" ;;
                        "320"|"323") weather_class="light-snow" ;;
                        "326"|"329") weather_class="snow" ;;
                        "332") weather_class="heavy-snow" ;;
                        "335") weather_class="light-snow-minimal" ;;
                        "338") weather_class="heavy-snow" ;;
                        "350") weather_class="hail" ;;
                        "353"|"356"|"359") weather_class="light-rain" ;;
                        "362"|"365") weather_class="sleet" ;;
                        "368"|"371") weather_class="snow" ;;
                        "374"|"377") weather_class="hail" ;;
                        "386") weather_class="thunder-minimal" ;;
                        "389"|"392") weather_class="thunder" ;;
                        "395") weather_class="heavy-snow" ;;
                        *) weather_class="cloudy" ;;
                    esac

                    echo "{\"text\": \" ${temp}°\", \"class\": \"$weather_class\", \"tooltip\": \"Weather | ${condition}  ${temp}°C\"}"
                else
                    echo "{\"text\": \"--°\", \"class\": \"weather\", \"tooltip\": \"Weather | No data\"}"
                fi
            else
                echo "{\"text\": \"--°\", \"class\": \"cloudy\", \"tooltip\": \"Weather | Error loading data\"}"
            fi
            ;;
    esac
}

main "$@"
