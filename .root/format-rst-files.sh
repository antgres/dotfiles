#! /usr/bin/bash

# stop script if command fails
set -e

readonly PANDOC_BIN="/usr/bin/pandoc"

_format-files () {
  local FILES="$@"

  if [ -d "$FILES" ]; then
    # check if input is a directory and get all files which are interesting
    FILES="$(ls $FILES/*rst)"
  fi

  for FILE in $FILES; do
        $PANDOC_BIN $FILE -f rst -t rst -s -o "$FILE"
	# change '\[\]' into '[]'
	sed -i 's#\\\[#[#g; s#\\\]#]#g' "$FILE"
	echo "Formated $(echo "$FILE" | grep -o '[^/]*$' )"
  done
}

_check-for-pandoc () {
    # test if pandoc installed and works
    if ! [ -x "$(command -v $PANDOC_BIN -h)" ]; then
        echo "pandoc not installed. Install pandoc"
        exit 1
    fi
}

_check-for-pandoc

while :; do
	if [ $# -gt 0 ]; then
	  # we got some files
          data_to_check="$@"
          question="Format $@"
	else
          # we want everything in the folder
	  folder=$(pwd)
	  data_to_check="$folder"
          question="Format everything in $folder"
        fi

	read -e -p "$question? (y/n) " answer

	case $answer in
		y) _format-files "$data_to_check"; exit;;
		n) exit;;
		*) echo "Please answer yes or no.";
	esac
done
