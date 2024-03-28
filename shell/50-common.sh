#!/usr/bin/env bash

package_exists(){
  # Check if a package is installed
  #  Usage:
  #    check_package_exists $PACKAGE_1
  local package="$1"

  if command -v "$package" > /dev/null; then
    true
  else
    false
  fi
}

die(){
  # die with message in red and bold
  printf "\33[2K\r\033[1;31m%s\033[0m\n" "Error: $*" >&2
  exit 1
}
