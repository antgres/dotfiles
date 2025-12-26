# [[ -f ~/.bash_aliases ]] && . ~/.bash_aliases


# Swap caps with esc in debian (gnome) wayland (compositor: mutter)
# gsettings set org.gnome.desktop.input-sources xkb-options '["caps:escape"]'

# Stop the software flow control so the terminal doesn't freeze up. If that
# happens use C-q to unfreeze it.
# https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
stty -ixon

# Eternal bash history.
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
# Note: sudo chattr +a ~/.bash_eternal_history
export HISTFILE=~/.bash_eternal_history
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
shopt -s histappend # if shell exists, append to history file
stophistory () {
  PROMPT_COMMAND="bash_prompt_command"
  echo 'History recording stopped. Make sure to `kill -9 $$` at the end of the session.'
}
# Preserve bash history in multiple terminal windows
HISTCONTROL=ignoredups:erasedups # Avoid duplicates

#setopt EXTENDED_HISTORY    # Write the history file in the ":start:elapsed;command" format.
#setopt INC_APPEND_HISTORY  # Write to the history file immediately, not when the shell exits.
#setopt SHARE_HISTORY       # Share history between all sessions.

## A whole lot of git
## ------------------

# !! root commit
# ! if only a single commit (root commit) is commited or one wants the root
# ! commit use the flag *--root* instead of $SHA.

alias g="git"
alias gitam="git am --3way --ignore-space-change --reject"
# Taken from https://coderwall.com/p/euwpig/a-better-git-log
alias gitlg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit"
# see log as oneliner
alias gitlo="git log --oneline"
# see diff of staged commits
alias gitsta="git diff --cached"
# show inline diffs
alias gitdi='git show --word-diff'
# remove all unstaged changes in repo
alias gitrm="git reset --hard"
# remove last commit from log
alias gitres="git reset HEAD~"
# add hunks of a file
alias gitap="git add -p"
# show history of moving HEAD, more info with --pretty=short
alias githis="git reflog --relative-date"
alias gitch="git cherry-pick"
# Usage: gitemail -v4 --to email@email.de --in-reply-to 424242422442000-email@.de 3a55fcd^
alias gitemail="git send-email --cover-letter --cc review@linutronix.de --no-chain-reply-to --annotate"
alias gitemail-dev="git send-email --cover-letter --no-chain-reply-to --annotate"
# create orphan branch. Usage: gitorph NEW-BRANCH
alias gitorph="git checkout --orphan"
# delete root commit (last commit in branch)
alias gitdelroot="git update-ref -d HEAD"
# cautious: clean all changes. dry run with -n option if unsure
alias gitmrclean="git clean -fd"
alias gitlblame="git blame -w -C -C -C"

gri(){
  # rebase into edit-todo interactivly via fzf
  # Usage: gri
  COMMIT="$(git log --oneline | \
    fzf -d " " --preview 'git show --color=always {1}' \
    --bind 'shift-up:preview-up,shift-down:preview-down' \
    --bind 'page-up:preview-page-up,page-down:preview-page-down' \
    --bind 'enter:execute(echo {1})+abort')"
  [ -n "$COMMIT" ] && git rebase -i ${COMMIT}^
}

gref(){
  # Look through "git reflog [FILE]" interactivly via fzf
  # Usage: gref

  FILE="${1:-}"
  COMMIT="$(git reflog ${FILE} | \
    fzf -d " " --preview 'git show --color=always {1}' \
    --bind 'shift-up:preview-up,shift-down:preview-down' \
    --bind 'page-up:preview-page-up,page-down:preview-page-down' \
    --bind 'enter:execute(echo {1})+abort')"
  [ -n "$COMMIT" ] && printf 'Commit: %s\n' "$COMMIT"
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

# reword the last commit
git_add_amend_edit(){
  # Add and amend file to last commit, but check if user wants to edit the
  # commit message or not
  # Usage:
  #  git_add_amend_edit [edit] # User wants to edit message
  #  git_add_amend_edit [edit] FILE # User wants to amend file and edit message
  #
  local flag="${1:-no-edit}"
  local file="$2"

  if [ -n "${file}" ]; then
    git add "${file}"
  fi

  git commit --amend --${flag}
}
alias ga="git_add_amend_edit edit"
alias gaa="git_add_amend_edit no-edit"

## common commands
check_package_exists(){
  # Test if package "exists" (is installed). Return true if yes, false if not.
  # usage: [ check_package_exists $PACKAGE_NAME] && do_stuff;
  local package="$1"

  if command -v "$package" > /dev/null; then
    true
  else
    false
  fi
}

## Yocto specific commands

# In commit messages the citation of other commits has the conanical format
# `<12 letters of SHA1> ("subject")`. Use a oneliner to generate this format.
# Usage:
#   gcf COMMIT_SHA
alias gcf="git show -s --abbrev=12 --pretty=format:'%h (\"%s\")'"

output_src_uri_correctly(){
  # Write files in a specific way out for SRC_URI.
  # Example
  #    Directory
  #      |- File-1
  #      |- File-2
  # is written out as via `src` inside Directory
  #     file://File-1 \
  #     file://File-2 \
  #
  ORIG="${1:-$PWD}"
  ls "$ORIG" | sed 's#^\(.*\)$#    file://\1 \\#g'
}
alias src="output_src_uri_correctly"

git_format_patch_cp() {
  # Format-patch the last patches and copy the correct command into the
  # cliboard buffer if path not decided yet
  # Usage:
  #   git_format_patch_cp # Format-patch the last commit
  #   git_format_patch_cp 5 # Format-patch the last five commits
  #   git_format_patch_cp 5 /path/to/layer/files # Format-patch the last five
  #                                              # commits and copy to
  #                                              # /path/to/layer/files
  #
  local quantity=${1:-1}
  local target="${2:-.}"
  local file_names="$(git format-patch -${quantity})"

  local list_of_files=""
  for file in ${file_names}; do
    list_of_files="${list_of_files} $(realpath "${file}")"
  done

  local command="cp -t ${target} ${list_of_files}"

  if [ "${target}" == "." ]; then
    printf "${command}" | xclip -sel clip -i
  else
    eval "${command}"
  fi
}
alias gfcp="git_format_patch_cp"

## simplify more complex commands
## ------------------------------
cd_up() {
  # jump from nested child into upper folder
  # usage: cd ../../.. -> cd.. 3
  cd $(printf "%0.s../" $(seq 1 $1 ));
}
alias 'cd..'='cd_up'
alias '..'='cd_up'

mkcd() {
  # Create directory and move into it.
  mkdir -p "$1" && cd "$1" || echo "Could not create $1"
}

findbiggestfile(){
  local root_path=${1:-"/"}
  local list_size="${2:-50}"
  sh -x -c "find ${root_path} -xdev -type f -size +100M -exec du -sh {} ';' 2>- \
            | sort -rh | head -n${list_size}"
}
findbiggestdirectories(){
  local root_path=${1:-"/"}
  local list_size="${2:-20}"
  sh -x -c "du -h --all --one-file-system ${root_path} 2>- | \
            sort -rh | head -n${list_size}"
}
alias fbf="findbiggestfile"
alias fbd="findbiggestdirectories"

trash(){
  # look up stuff in the trash directory
  # Usage:
  #  trash      # list content of trash directory
  #  trash pdf  # show all files with pdf in name in trash directory
  local trash_path="${HOME}/.local/share/Trash/files"

  if [ $# -eq 0 ]; then
    ll "$trash_path"
  elif [ $# -eq 1 ]; then
    ll "${trash_path}"/*"$1"* 2>/dev/null ||\
    echo "WARNING Could not find any file with '$1' in it"
  else
    echo "ERROR: Multiple arguments are not supported."
  fi
}

open(){
  # open the graphical GUI. if no argument is given open the current path the
  # user is in
  local directory="$PWD"
  [ $# -gt 0 ] && directory="$1"

  xdg-open "$directory" >/dev/null 2>&1
}

myip(){
  # Display the used IP which will used to connect to the server
  # with the IP 8.8.8.8.
  # Usage:
  #   myip    # Display only the used IP
  #   myip a  # Display the output of the ip route command

  value="$(ip route get 8.8.8.8)"

  if [ "$1" == "a" ]; then
    echo "$value"
  else
    echo "$value" | cut -f7 -d" "| grep -v '^$'
  fi
}

## abbreviations
## -------------
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
# start at the end of file and tail the file
alias lesendf="less +F"

# shred the file by overwriting with random data,
# then zeros and lastly deleting
alias shredd="shred -v -n 1 -z -u"

# distrobox
alias enter="distrobox enter"

_fzf_history(){
  # Print the command found in history as input back to the terminal
  if [ "$1" = "--print" ]; then
    print="1"
    # remove flag from $@
    shift
  fi

  # search unique lines in bash history to execute again
  local QUERY="${@:-}" # take argument which is provided
  local COMMAND="$(uniq -u ${HISTFILE} | fzf -i --tac --no-sort --exact --query "${QUERY}")"

  if [ "$print" = "1" ]; then
    # HACK: Only works for tmux
    ID="$(tmux display-message -p '#S:#I')"
    tmux send-keys -t "${ID}" "${COMMAND}"
  else
    # save to history to find it later too
    echo "$COMMAND" >> ${HISTFILE}
    # execute command again
    eval $COMMAND 
  fi
}

# bash specific - ignore history for command which matches condition
export HOSTIGNORE="h *:H *"

_fzf_man(){
  # look through all manpages (apropos) and open the wanted
  local QUERY="${@:-}" # take argument which is provided
  man -k . | fzf -i --tac --no-sort --exact --query "${QUERY}" |\
  sed -E 's#^(.*) \((.)\).*#\1(\2)#g' | xargs -I{} man {}
}
alias H="_fzf_history --print"
alias h="_fzf_history"
alias m="_fzf_man"

i_hate_outlook_365(){
  # prepend all the text in the primary clipboard buffer with the char '>' and
  # the correct amount of whitespace because outlook365 does not support that
  # for replys (the normal windows outlook app does that).
  # Example:
  #   > I love cats.
  #   \n
  #   Me too.
  # Transforms to:
  #   >> I love cats.
  #   >\n
  #   > Me too.
  xclip -sel prim -o |\
  sed -e 's/^>/>>/g' -e 's/^$/>/g' -e 's/^[^>]/> &/g' |\
  xclip -sel clip -i
}
alias outlook="i_hate_outlook_365"

## custom abbreviations
## --------------------
_update_all_panes(){
  # Write and execute a command for all panes (intended way: refresh
  # bash_aliases)
  # Note: Depending on what is executed currently in a pane (for example less
  # or man), the command is wrongly executed. Watch out.
  COMMAND="${@:-source $HOME/.bash_aliases}"

  for pane in $(tmux list-panes -a -F '#S:#I.#P'); do
    tmux send-keys -t ${pane} "${COMMAND}" Enter
  done
}


# Update dotfiles
ud() {
  (cd ~/.dotfiles && git pull --ff-only && ./install -q)
}

alias scratch="$EDITOR $(mktemp)"

# open correctly a new terminal screen and session
alias tm="GNOME_TERMINAL_SCREEN='' gnome-terminal >/dev/null 2>&1"

# Get a) the current tag, b) the current branch or c) the commit SHA. Prefix
# the result with a whitespace.
git_ps1() {
  # If not a git directory do not execute commands
  [ -d "$PWD/.git" ] || return
  NAME="$( (git describe --tags --exact-match || git branch --show-current) 2>/dev/null)"
  # If no tag or branch name fits just take the commit hash
  [ -z "${NAME}" ] && NAME="$(printf 'Detached %s' "$(git rev-parse HEAD | head -c 12)")"
  printf '%s' "${NAME}" | sed -n '/./ s/^/ /p'
}
export PS1='\[\e[0;91m\][\[\e[0;93m\]\u\[\e[0;92m\]@\[\e[0;38;5;32m\]\h \[\e[0;38;5;207m\]\w\[\e[0m\]$(git_ps1)\[\e[0;91m\]]\[\e[0;1m\]\n$ \[\e[0m\]'

alias v="nvim"
alias et="emacs -nw"
alias n="nano"

_command_stats() {
  # Print out stats about occurrence of commands.
  # https://hackaday.com/2024/12/22/optimizing-your-linux-shell-experience/
  local AMOUNT="$1"

  history | \
  awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | \
  grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n $AMOUNT
}

## package manager
## ---------------

alias a="sudo apt"
alias au="sudo sh -c 'apt update && apt list --upgradable'"
alias auu="sudo apt upgrade"
alias p="sudo pacman"
alias pu="sudo sh -c ' pacman -Syy --needed --noconfirm archlinux-keyring && pacman -Qu'"
alias puu="sudo pacman -Su"

aptremove(){
  # Remove all residual packages (aka configurations files of uninstalled
  # packages). See `man apt-get`
  # - purge: identical to remove except that packages are removed and purged
  #          (any configuration files are deleted too) (but not logs).
  sudo apt remove --purge $(dpkg -l | awk '/^rc/{print $2}')
}

aptorph(){
  # Remove all orphan packages
  sudo apt remove --purge $(dpkg -l | awk '/^iU/{print $2}')
}

pacclean(){
  # https://ostechnix.com/recommended-way-clean-package-cache-arch-linux/
  # 1) delete the package cache except the latest version
  # 2) Remove all uninstalled packages
  sudo sh -c "paccache -rk 1; pacman -Sc"
}

pacorph(){
  # get all orphan packages and delete them
  sudo sh -c 'orphan=$(pacman -Qtdq); [ -z $orphan ] && exit 0 || pacman -Rns $orphan'
  pacclean
}

packeys(){
  # refresh gpg keys (takes long)
  # See
  #    https://wiki.archlinux.org/title/Pacman/Package_signing#Troubleshooting
  # for more information
  # In the worst case: Reset the keys with
  #   sudo sh -c '\
  #        pacman -Syy archlinux-keyring && \
  #        rm -r rm -r /etc/pacman.d/gnupg/ && \
  #        pacman-key --init && \
  #        pacman-key --populate \
  #   '
  sudo sh -c "sudo pacman-key --refresh-keys"
}
