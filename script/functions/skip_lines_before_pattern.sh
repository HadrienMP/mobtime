#!/usr/bin/env sh

skip_lines_before_pattern() {
	PATTERN="$1"
	# https://askubuntu.com/a/961541
	awk "/${PATTERN}/{f=1}f"
}
