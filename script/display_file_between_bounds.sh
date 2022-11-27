#!/usr/bin/env sh

PROJECT_ROOT=$(dirname "$(realpath $0)")/..

. "${PROJECT_ROOT}/script/functions/skip_lines_before_pattern.sh"
. "${PROJECT_ROOT}/script/functions/skip_lines_after_pattern.sh"

display_file_between_bounds() {
	START_PATTERN="$1"
	END_PATTERN="$2"

	skip_lines_before_pattern "${START_PATTERN}" |
		skip_lines_after_pattern "${END_PATTERN}"
}
