#!/usr/bin/env sh
SOUNDS=$(find public -type f -name "*.mp3")
yes | mp3gain -r -q -c $SOUNDS
