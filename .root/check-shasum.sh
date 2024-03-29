#! /usr/bin/bash

file="$1"
hash="$2"

# check for missing information
if [ -z "$file" ] || [ -z "$hash" ]; then
  printf "Missing FILENAME or HASH. Please provide.\n"
  exit 1
fi

algorithm=256
if [ -n "$3" ]; then
  algorithm="$3"
fi

echo "$hash *$file" | shasum -a "$algorithm" --check
