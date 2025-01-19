#!/usr/bin/env bash
#
# Search through the tldr markdown files via fzf.
# Note: The tldr package must be installed.
#

LANGUAGE="en"
BASE_TLDR_PATH="$HOME/.local/share/tldr/pages.${LANGUAGE}"

tldr \
$(ls -1 -A $BASE_TLDR_PATH/{common,linux} | grep -v -e / -e "^$" | \
cut -d '.' -f1 | fzf -i --exact)
