#!/usr/bin/env bash

alias p="sudo pacman"

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
  sudo sh -c "sudo pacman-key --refresh-keys"
}
