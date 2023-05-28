# [[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# change bash_history to save more entries
HISTSIZE=10000000
SAVEHIST=10000000

# Preserve bash history in multiple terminal windows
HISTCONTROL=ignoredups:erasedups # Avoid duplicates
shopt -s histappend # if shell exists, append to history file

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

## A whole lot of git
## ------------------

# !! root commit
# ! if only a single commit (root commit) is commited or one wants the root
# ! commit use the flag *--root* instead of $SHA.

# see log as oneliner
alias gitlo="git log --oneline"
# see diff of staged commits
alias gitsta="git diff --cached"
# reword the last commit
alias gitrew="git commit --amend --edit"
# remove all unstaged changes in repo
alias gitrm="git checkout -- ."
# remove last commit from log
alias gitres="git reset HEAD~"
# rebase log interactivly
alias gitri="git rebase -i"
# add hunks of a file
alias gitap="git add -p"
# show history of moving HEAD, more info with --pretty=short
alias githis="git reflog --relative-date"
alias gitchy="git cherry-pick"
# Usage: gitemail -v4 --to email@email.de --in-reply-to 424242422442000-email@.de 3a55fcd^
alias gitemail="git send-email --cover-letter --cc review@linutronix.de --no-chain-reply-to --annotate"
alias gitemail-dev="git send-email --cover-letter --no-chain-reply-to --annotate"
# create orphan branch. Usage: gitorph NEW-BRANCH
alias gitorph="git checkout --orphan"
# delete root commit (last commit in branch)
alias gitdelroot="git update-ref -d HEAD"
# cautious: clean all changes, dry run with -n option
alias gitmrclean="git clean -fd"

# show log with -L option
gitloli() {
  # Use: gitloli FILE LINE
  # Show log of range of lines (here: single line)
  if (( $# >= 0 && $# <= 2 )); then
    if (( $# == 1 )); then
      # check single file
      git log -p -- $1
    else
      # check LINE
      git log -L $2,$2:$1
    fi
  else
    echo "Wrong amount of inputs."
  fi
}

# append reviewed-by until HASH
gitrb() {
  # Usage: gitrb "Max Mustermann" "max@mustermann.de" <HASH>

  export who="$1"
  export mail="$2"
  export head="$3"

  git rebase $head \
  -x 'git commit --amend -m"$(git log --format=%B -n1) $(echo "\nReviewed-by: $who <$mail>")"'
}

gitaddcontinue(){
  ## How to rebase
  #
  # 1) Rebase to the to be changed commit SHA.
  #       git rebase -i $SHA^
  # 2) Add changes to the commit.
  # 3) Add changes (eg. git add -p)
  # 4) Commit changes without changing the existing
  #    commit message
  #       git commit --amend --no-edit
  # 5) Continue rebasing
  #       git rebase --continue
  #

  _gitcontinue(){
    git add $*
    git commit --amend --no-edit
    git rebase --continue
  }

  # This function is only to be used in a rebase
  # Amend a file and continue the rebase
  read -e -p "Add and continue with $* ? (y/n) " answer

  case $answer in
    y) _gitcontinue $*;;
    *);;
  esac

}
alias gitcon="gitaddcontinue"


## simplify more complex commands
## ------------------------------
splitsen () {
  # Cut line after around 78 chars
  # recommended in
  # https://people.kernel.org/tglx/notes-about-netiquette
  echo $1 | sed 's/./&\n/78'
}

cd_up() {
  # jump from nested child into upper folder
  # ex. cd ../../.. -> cd.. 3
  cd $(printf "%0.s../" $(seq 1 $1 ));
}
alias 'cd..'='cd_up'

copy(){
  # redirect something into the clipboard buffer
  if [ -f $1 ]; then
    xclip -sel clip < $1
  else
    "$@" | xclip -sel clip
  fi
}

ex () {
  # # from Manjaro .bashrc
  # # ex - archive extractor
  # # usage: ex <file>
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
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
findbiggestdirectories(){
  local root_path=${1:-"/"}
  local list_size="${2:-20}"
  sh -x -c "du -h --all --one-file-system ${root_path} | \
            sort -rh | head -n${list_size}"
}
alias fbf="findbiggestfile"
alias fbd="findbiggestdirectories"

trash(){
  # look up stuff in the trash folder
  local trash_path="${HOME}/.local/share/Trash/files"

  if [ $# -eq 0 ]; then
    ll "$trash_path"
  elif [ $# -eq 1 ]; then
    local key
    ll "${trash_path}"/*"$1"*
  else
    echo "ERROR Multiple arguments are not supported."
  fi
}

## abbreviations
## -------------

alias SS="sudo systemctl"
alias ssn="sudo shutdown -h now"
alias srn="sudo reboot"

alias hs="history | tail -30"
alias ghis="history | grep"

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

## custom abbreviations
## --------------------
alias format-rst="~/.dotfiles/scripts/format-rst-files.sh"
alias ytmp3="yt-dlp -x -f bestaudio --audio-format mp3 --add-metadata\
             --embed-thumbnail --no-keep-video"

tmux-dev () {
  tmux new-session \; \
  split-window -h \; \
  #send-keys 'tail -f /var/log/monitor.log' C-m \; \
  #split-window -v \; \
  #split-window -h \; \
  #send-keys 'top' C-m \;
}
alias tmd="tmux-dev"
## open correctly a new terminal screen and session
alias tm="GNOME_TERMINAL_SCREEN='' gnome-terminal >/dev/null 2>&1"

__git_ps1() { git branch 2>/dev/null | sed -n 's/* \(.*\)/ \1/p'; }
export PS1='\[\e[0;91m\][\[\e[0;93m\]\u\[\e[0;92m\]@\[\e[0;38;5;32m\]\h \[\e[0;38;5;207m\]\w\[\e[0m\]$(__git_ps1)\[\e[0;91m\]]\[\e[0;1m\]\n$ \[\e[0m\]'

alias open='xdg-open . >/dev/null 2>&1 &'
alias v="nvim"
alias et="emacs -nw"

## package manager
## ---------------

alias p="sudo pacman"
alias a="sudo apt"
alias au="sudo sh -c 'apt update && apt list --upgradable'"

pac-orph(){
  # get all orphan packages and delete them
  sudo sh -c 'orphan=$(pacman -Qtdq); [ -z $orphan ] && exit 0 || pacman -Rns $orphan'
}

pacclean(){
  # https://ostechnix.com/recommended-way-clean-package-cache-arch-linux/
  # 1) delete the package cache except the latest version
  # 2) Remove all uninstalled packages
  sudo sh -c "paccache -rk 1; pacman -Sc"
}
