#!/usr/bin/env bash

# customize prompt string
__git_ps1() { git branch 2>/dev/null | sed -n 's/* \(.*\)/ \1/p'; }
export PS1='\[\e[0;91m\][\[\e[0;93m\]\u\[\e[0;92m\]@\[\e[0;38;5;32m\]\h \[\e[0;38;5;207m\]\w\[\e[0m\]$(__git_ps1)\[\e[0;91m\]]\[\e[0;1m\]\n$ \[\e[0m\]'

cd_up() {
  # jump from nested child into upper folder
  # ex. cd ../../.. -> cd.. 3
  cd $(printf "%0.s../" $(seq 1 $1 ));
}
alias 'cd..'='cd_up'
alias '..'='cd_up'

ex () {
  # # from Manjaro .bashrc
  # # ex - archive extractor
  # # usage: ex <file>
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  elif [ "$1" == "-help" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: ex <file>"
    echo "Supported archives:"
    echo "    tar.bz2, tar.gz, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z"
  else
    echo "Unkown argument. Try -h"
  fi
}

findbiggestfile(){
  local root_path=${1:-"/"}
  local list_size="${2:-50}"
  sh -x -c "find ${root_path} -xdev -type f -size +100M -exec du -sh {} ';' \
            | sort -rh | head -n${list_size}"
}
alias fbf="findbiggestfile"

findbiggestdirectories(){
  local root_path=${1:-"/"}
  local list_size="${2:-20}"
  sh -x -c "du -h --all --one-file-system ${root_path} | \
            sort -rh | head -n${list_size}"
}
alias fbd="findbiggestdirectories"

trash(){
  # look up stuff in the trash folder
  local trash_path="${HOME}/.local/share/Trash/files"

  if [ $# -eq 0 ]; then
    ll "$trash_path"
  elif [ $# -eq 1 ]; then
    ll "${trash_path}"/*"$1"* 2>/dev/null ||\
    echo "WARNING Could not find any file with '$1' in it"
  else
    echo "ERROR Multiple arguments are not supported."
  fi
}

open(){
  # open the graphical folder. if no argument is given
  # open the current path the user is in
  local folder="$PWD"
  if [ $# -gt 0 ]; then
    folder="$1"
  fi
  xdg-open "$folder" >/dev/null 2>&1
}

myip(){
  # Display the used IP which will used to connect to the server
  # with the IP 8.8.8.8.
  # Usage:
  #        myip    # Display only the used IP
  #        myip a  # Display the output of the ip route command

  value="$(ip route get 8.8.8.8)"

  if [ "$1" == "a" ]; then
    echo "$value"
  else
    echo "$value" | cut -f7 -d" "| grep -v '^$'
  fi
}

##
## Other example fzf shell functions can be found at
## # https://github.com/junegunn/fzf/wiki/examples
##

_fzf_history(){
  # search unique lines in bash history execute again
  QUERY="${@:-}" # take argument which is provided
  COMMAND="$(uniq -u ~/.bash_history | fzf -i --tac --no-sort --exact --query "${QUERY}")"
  # save to history to find it later too
  echo "$COMMAND" >> ~/.bash_history
  eval $COMMAND # execute command
}
alias h="_fzf_history"

_fzf_man(){
  # look thorugh all manpages (apropos) and open the wanted
  QUERY="${@:-}" # take argument which is provided
  man -k . | fzf -i --exact --query "${QUERY}" | sed -E 's#^(.*) \((.)\).*#\1(\2)#g' | xargs -I{} man {}
}
alias m="_fzf_man"

tmux-dev(){
  tmux new-session \; \
  split-window -h \; \
  #send-keys 'tail -f /var/log/monitor.log' C-m \; \
  #split-window -v \; \
  #split-window -h \; \
  #send-keys 'top' C-m \;
}
alias tmd="tmux-dev"

ud() {
    # Update dotfiles
    (cd ~/.dotfiles && git pull --ff-only && ./install)
}
