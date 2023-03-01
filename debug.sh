#!/usr/bin/env bash
_DISPLAY=':4'
CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$CONFIG_DIR" || exit 1

#Xephyr "$_DISPLAY" -dpi 96x96 -ac -br -noreset -screen 1600x900&
Xephyr "$_DISPLAY" -dpi 96x96 -ac -br -noreset -screen 1920x1080 \
	-keybd ephyr,,,xkbmodel=pc105,xkblayout=de,xkbrules=evdev,xkboption=grp:nodeadkeys&
sleep 1 # Just making sure that Xephyr has been started up fully.

export DISPLAY="$_DISPLAY"

# If virtualgl is installed
if [[ "$NO_VIRTUALGL" != true ]] && command -v vglclient 2> /dev/null; then
	vglclient -detach
	env -C "$HOME" vglrun awesome --config "$CONFIG_DIR/rc.lua"&
else
	env -C "$HOME" awesome --config "$CONFIG_DIR/rc.lua"&
fi

# Allow commands to be typed in the VScode debug terminal.
printf '\nDebugging awesome using Xephyr.\n\n'

while true; do
	printf '> '
	read -r next_command
	awesome-client $'do local awful=require("awful");local gears=require("gears");local wibox=require("wibox")\n'"$next_command"$'\nend'
done
