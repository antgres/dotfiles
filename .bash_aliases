# [[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

HISTSIZE=10000000
SAVEHIST=10000000

# specific commands for git
alias gitlo="git log --oneline"
alias gitsta="git diff --cached"
alias gitrm="git checkout --"
alias gitre="git reset HEAD~"
alias gitri="git rebase -i"
alias gitap="git add -p"
alias githis="git reflog --relative-date"
alias gitchy="git cherry-pick"
# Usage: gitemail -v4 --to email@email.de --in-reply-to 424242422442000-email@.de 3a55fcd^
alias gitemail="git send-email --cover-letter --cc review@linutronix.de --no-chain-reply-to --annotate"
alias gitemail-dev="git send-email --cover-letter --no-chain-reply-to --annotate"
# create orphan branch. Usage: gitorph NEW-BRANCH
alias gitorph="git checkout --orphan"
# delete root commit (last commit in branch). Usage: gitdelroot
alias gitdelroot="git update-ref -d HEAD"
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
# adds reviwed-by to n commits
gitrb() {
  # Usage: git-rb "Max Mustermann" "max@mustermann.de" <HASH>

  export who="$1"
  export mail="$2"
  export head="$3"

  git rebase $head \
  -x 'git commit --amend -m"$(git log --format=%B -n1) $(echo "\nReviewed-by: $who <$mail>")"'
}

gitremember(){
  echo "Rebase a commit and ammend changes to it."
  echo ""
  echo "1) Rebase to the to be changed commit SHA."
  echo '    git rebase -i $SHA^'
  echo "2) Add changes to the commit."
  echo "3) Add changes (eg. git add -p)"
  echo "4) Commit changes"
  echo "  (without changing the existing commit message)"
  echo "    git commit --amend --no-edit"
  echo "5) Continue rebasing"
  echo "    git rebase --continue"
  echo ""
}
# -------------------------------------
splitsen () {
  # Cut line after X chars
  echo $1 | sed 's/./&\n/74'
}

# # from Manjaro .bashrc
# # ex - archive extractor
# # usage: ex <file>
ex () {
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

alias p="sudo pacman"
alias a="sudo apt"

alias SS="sudo systemctl"
alias ssn="sudo shutdown -h now"
alias srn="sudo reboot -h now"

alias hs="history | tail -30"
alias ghis="history|grep"

alias ls="ls -hN -v --color=auto --group-directories-first"
alias ll='ls -l'
alias l='ll'
alias lll='ll'

alias nau='nautilus . &'

alias et="emacs -nw"

# --------------------------------------
alias format-rst="~/.dotfiles/scripts/format-rst-files.sh"

tmux-dev () {
  tmux new-session \; \
  split-window -h \; \
  #send-keys 'tail -f /var/log/monitor.log' C-m \; \
  #split-window -v \; \
  #split-window -h \; \
  #send-keys 'top' C-m \;
}
alias tmd="tmux-dev"
alias tm="GNOME_TERMINAL_SCREEN='' gnome-terminal >/dev/null 2>&1"

__git_ps1() { git branch 2>/dev/null | sed -n 's/* \(.*\)/ \1/p'; }
export PS1='\[\e[0;91m\][\[\e[0;93m\]\u\[\e[0;92m\]@\[\e[0;38;5;32m\]\h \[\e[0;38;5;207m\]\w\[\e[0m\]$(__git_ps1)\[\e[0;91m\]]\[\e[0;1m\]$ \[\e[0m\]'

pac-orph(){
  sudo sh -c 'orphan=$(pacman -Qtdq); [ -z $orphan ] && exit 0 || pacman -Rns $orphan'
}
