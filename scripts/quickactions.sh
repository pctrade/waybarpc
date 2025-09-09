#!/usr/bin/env bash

case "$1" in
    --bluetooth)
        state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

        if [[ "$state" == "yes" ]]; then
            state="On"
            class="BTOn"
        else
            state="Off"
            class="BTOff"
        fi

        echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Bluetooth  $state\"}"
       ;;
    --network)
        if ip link show up | grep -q "state UP"; then
            state="On"
            class="NetOn"
        else
            state="Off"
            class="NetOff"
        fi

        echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Network  $state\"}"
       ;;
    --battery)
            battery=$(upower -e | grep battery | head -n1)
            battery_info=$(upower -i "$battery")
            percent=$(echo "$battery_info" | grep -E "percentage" | awk '{print $2}' | tr -d '%' | cut -d'.' -f1)
            state=$(echo "$battery_info" | grep -E "state" | awk '{print $2}')

            if [[ "$state" == "charging" ]]; then
                class="charging"
            elif (( percent < 33 )); then
                class="Low"
            elif (( percent < 66 )); then
                class="Med"
            else
                class="Full"
            fi

            echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Battery | ${percent}%  $state\"}"
        ;;
    --volume)
            volume_info=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')
            mute_status=$(pactl get-sink-mute @DEFAULT_SINK@)

                if [[ "$mute_status" == *"yes" ]]; then
                    class="volmute"
                elif (( volume_info < 33 )); then
                    class="volow"
                elif (( volume_info < 66 )); then
                    class="volmed"
                else
                    class="volfull"
                fi

            echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Volume  ${volume_info}%\"}"
        ;;
    --nerd)
        echo "{\"text\": \" \", \"class\": \"nerd\", \"tooltip\": \"    Nerd Icons\"}"
        ;;
    --clipboard)
        echo "{\"text\": \" \", \"class\": \"clipboard\", \"tooltip\": \"   Clipboard\"}"
        ;;
    --power)
        echo "{\"text\": \" \", \"class\": \"power\", \"tooltip\": \"Power Menu\"}"
        ;;
    --logo)
        echo "{\"text\": \" \", \"class\": \"logo\", \"tooltip\": \"Apps Launcher\"}"
        ;;
    --config)
        echo "{\"text\": \" \", \"class\": \"config\", \"tooltip\": \"   Configs\"}"
        ;;
    --theme)
        echo "{\"text\": \" \", \"class\": \"theme\", \"tooltip\": \"󱥚   Themes\"}"
        ;;
    --wallpapers)
        echo "{\"text\": \" \", \"class\": \"wallpapers\", \"tooltip\": \"  Wallpapers\"}"
        ;;
    --screenshot)
        echo "{\"text\": \" \", \"class\": \"screenshot\", \"tooltip\": \"  Screenshots | Click Select  Right Click Output\"}"
        ;;
    --record)
        statusrecord=$(cat ~/.config/waybar/cache/isrecording 2>/dev/null | tr -d '[:space:]')

            if [ "$statusrecord" = "on" ]; then
                echo "{\"text\": \" \", \"class\": \"recordon\", \"tooltip\": \"   Recording  Right Click to stop\"}"
            else
                echo "{\"text\": \" \", \"class\": \"recordoff\", \"tooltip\": \"   Record\"}"
            fi
        ;;

    --picker)
        echo "{\"text\": \" \", \"class\": \"picker\", \"tooltip\": \"   Click Change Accent  Right Click Change Accent2\"}"
        ;;
    *)
        echo "{\"text\": \" \", \"class\": \"config\", \"tooltip\": \"Quick Actions  CONFIG\"}"
        ;;
esac
