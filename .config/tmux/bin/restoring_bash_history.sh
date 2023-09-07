#! /bin/bash

#
# used suggestion from the repo tmux-plugins/tmux-resurrect
# in docs/restoring_bash_history.md
#

pane_id_prefix="resurrect_"

# Create history directory if it doesn't exist
HISTS_DIR=$HOME/.bash_history.d
mkdir -p "${HISTS_DIR}"

if [ -n "${TMUX_PANE}" ]; then

  # Check if we've already set this pane title
  pane_id=$(tmux display -pt "${TMUX_PANE:?}" "#{pane_title}")
  if [[ $pane_id != "$pane_id_prefix"* ]]; then

    # if not, set it to a random ID
    random_id=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
    printf "\033]2;$pane_id_prefix$random_id\033\\"
    pane_id=$(tmux display -pt "${TMUX_PANE:?}" "#{pane_title}")
  fi

  # use the pane's random ID for the HISTFILE
  export HISTFILE="${HISTS_DIR}/bash_history_tmux_${pane_id}"
else
  export HISTFILE="${HISTS_DIR}/bash_history_no_tmux"
fi

# Stash the new history each time a command runs.
export PROMPT_COMMAND="$PROMPT_COMMAND;history -a"
