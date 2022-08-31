#! /usr/bin/bash

# stop script if command fails
set -e

readonly PANDOC_BIN="/usr/bin/pandoc"

_format-files () {
  readonly FORMAT_DIR="$1"
  readonly FILES="$(ls $FORMAT_DIR/*rst)"

  for FILE in $FILES; do
        $PANDOC_BIN $FILE -f rst -t rst -s -o $FILE
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
# Ask the question
FORMAT_DIR=$(pwd)
while :; do
	read -e -p "Format everything in "$FORMAT_DIR" ? (y/n) " answer

	case $answer in
		y) _format-files "$FORMAT_DIR"; exit;;
		n) exit;;
		*) echo "Please answer yes or no.";
	esac
done
