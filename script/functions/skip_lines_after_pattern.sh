#!/usr/bin/env sh

skip_lines_after_pattern() {
	PATTERN="$1"
	# https://unix.stackexchange.com/a/11323
	sed "/${PATTERN}/q"
}
