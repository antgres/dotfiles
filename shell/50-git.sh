#!/usr/bin/env bash
#
# INFO: root commits
#   If only a single commit (root commit) is created or one wants the root
#   commit use the flag *--root* instead of $SHA.
#

# Better UI log
# Taken from https://coderwall.com/p/euwpig/a-better-git-log
alias gitlg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit"
# see log as oneliner
alias gitlo="git log --oneline"
# see diff of staged commits
alias gitsta="git diff --cached"
# reword the last commit
alias gita="git commit --amend --edit"
alias gitna="git commit --amend --no-edit"
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

gri(){
    # rebase log interactivly via fzf
    # Usage: gri
    COMMIT="$(git log --oneline | fzf | cut -d' ' -f1)"
    git rebase -i ${COMMIT}^
}

gitloli() {
    # Show log for range of lines (here: single line)
    # Usage:
    #        gitloli FILE
    #        gitloli 15 FILE
    #        gitloli 15 20 FILE
    if (( $# == 1 )); then
      # show detailed and complete history of file
      git log --full-diff $1
    elif (( $# == 2 )); then
      # check SINGLE LINE
      git log -L $1,$1:$2
    elif (( $# == 3 )); then
      # check LINE RANGE
      git log -L $1,$2:$3
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
