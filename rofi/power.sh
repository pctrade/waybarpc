#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/waybar/rofi"
theme='powermenu'

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"

# Options
shutdown='󰐦'
reboot='󰑓'
lock='󰍁'
suspend='󰤄'
logout='󰍃'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "Goodbye ${USER}" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	case "$1" in
		--shutdown) systemctl poweroff ;;
		--reboot)   systemctl reboot ;;
		--suspend)
			mpc -q pause 2>/dev/null
			amixer set Master mute
			systemctl suspend
			;;
		--lock) hyprlock &;;
		--logout)   hyprctl dispatch exit ;;
	esac
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown) run_cmd --shutdown ;;
    $reboot)   run_cmd --reboot ;;
    $lock)     run_cmd --lock;;
    $suspend)  run_cmd --suspend ;;
    $logout)   run_cmd --logout ;;
esac
