#!/usr/bin/env bash

FOLDER="${1-history}"
ENTRIES="$(find "$FOLDER" -type f -name '*.txt' | grep -v "$(readlink "$FOLDER"/last)")"
[ -n "$ENTRIES" ] && rm "$ENTRIES"
