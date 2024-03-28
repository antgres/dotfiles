#!/usr/bin/env bash
#
# Configuration for bash
#

# change number of bash_history lines to save
# (in this case: do not delete any)
HISTSIZE=""
SAVEHIST=""

# Preserve bash history in multiple terminal windows
HISTCONTROL=ignoredups:erasedups # Avoid duplicates
shopt -s histappend # if shell exists, append to history file

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

