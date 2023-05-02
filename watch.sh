#!/usr/bin/env bash
clear

#LUA_VERSION="${LUA_VERSION:-5.1}"

# LuaJIT supports some 5.2 features like `goto`
LUA_VERSION="${LUA_VERSION:-5.2}"

# yue --target="$LUA_VERSION" -w "$PWD"

clear
yue .

function wait_for_change() {
	inotifywait --event modify \
		--include '.*\.yue' \
		--recursive ./ \
		2> /dev/null |
		awk '{ printf "%s%s\n", $1, $3 }'
}

function compile() {
	yue -c --target="$LUA_VERSION" "$1"
}

while true; do
	yue_file="$(wait_for_change)"
	#lua_file="${yue_file%.yue}.lua"
	#wait_for_change
	clear
	compile "$yue_file"
	#"luac$LUA_VERSION" -s -o "$lua_file" "$lua_file"
done
