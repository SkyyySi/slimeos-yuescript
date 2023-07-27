#!/usr/bin/env bash
clear
echo 'Listening for changes to .c files...'

while true; do
	file=$(inotifywait --event create --event modify --event moved_to --event move_self --include '.*\.c$' --recursive "$PWD" --format '%w%f' 2> /dev/null)

	clear

	gcc \
		-std=c11 \
		-Werror-implicit-function-declaration \
		-shared \
		-fPIC \
		$(pkg-config --cflags --libs gtk+-3.0 glib-2.0 gio-2.0 gio-unix-2.0 luajit cairo) \
		-lm \
		"$file" \
		-o \
		"${file%.c}.so"

	if (($? == 0)); then
		echo "Compiled '${file//$PWD/.}' successfully."
	fi
done
