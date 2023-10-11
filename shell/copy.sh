#!/usr/bin/env bash
#
# copy strings or files into the CLIPBOARD and PRIMARY buffer
#

check_package_exists(){
  local package="$1"

  if command -v "$package" > /dev/null; then
    true
  else
    false
  fi
}


SILENT=1

while getopts "s" INPUT; do
  case $INPUT in
    s)
      SILENT=0
      ;;
  esac
done
shift $((OPTIND-1))

INPUT="$@" # get all other INPUTuments
if ! [ "${INPUT}" ]; then
  # check if input present
  echo "No valid input '${INPUT}'"
return
fi

# check all possible inputs if they are a file else they are all strings
NO_FILE=true;
for file in ${INPUT}; do
  if [ ! -f "$file" ]; then
    NO_FILE=false;
    break;
  fi
done

if check_package_exists xclip; then
  (( SILENT )) && printf "Using xclip.\n"
  if $NO_FILE ; then
    (( SILENT )) && printf "File '%s' copied.\n" "$INPUT"
    xclip -sel prim -i $INPUT
  else
    (( SILENT )) && printf "String '%s' copied.\n" "$INPUT"
    echo "$INPUT" | xclip -sel prim
  fi
  exit 0
fi

if check_package_exists xsel; then
  (( SILENT )) && printf "Using xsel.\n"
  if $NO_FILE ; then
    (( SILENT )) && printf "File '%s' copied.\n" "$INPUT"
    xsel --primary < $INPUT
  else
    (( SILENT )) && printf "String '%s' copied.\n" "$INPUT"
    echo "$INPUT" | xsel --primary
  fi
  exit 0
fi

printf "%s %s\n" "No supported application found to copy with."\
"Install either 'xsel' or 'xclip'."
