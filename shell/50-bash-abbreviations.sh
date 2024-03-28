#!/usr/bin/env bash

alias SS="sudo systemctl"
alias ssn="sudo shutdown -h now"
alias srn="sudo reboot"

alias ls="ls -hN -v --color=auto --group-directories-first"
alias ll='ls -l'
alias l='ll'
alias lll='ll'

# start at the end of the file
alias lesend="less +G"
# start at the end of file and continually load new content
alias lesendf="less +F"

# shred the file by overwriting with random data,
# then zeros and lastly deleting
alias shredd="shred -v -n 1 -z -u"

# distrobox
alias enter="distrobox enter"

## open correctly a new terminal screen and session
alias tm="GNOME_TERMINAL_SCREEN='' gnome-terminal >/dev/null 2>&1"

## Archived
## --------
#alias hs="history | tail -30"
#alias ghis="history | grep"
