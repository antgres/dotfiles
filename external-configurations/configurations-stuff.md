# dotfiles



# Additional modifications

## cronjobs

```
[root]
# Only download to be updated packages
# every 2h05m
## 5m because of interference of other pacman stuff
5 */2 * * * /usr/bin/pacman -Syuw --noconfirm
*/30 * * * * /usr/bin/updatedb

[user]
* */6 * * * /usr/bin/tldr -u
```

## Link collection

https://github.com/LunarVim/Neovim-from-scratch

# tmux config
https://github.com/gpakosz/.tmux

# vim config
https://github.com/shubmehetre/dotfiles

https://www.linuxtopia.org
https://kernelnewbies.org

## programs

autocutsel xclip xsel pandoc codium tldr tmux zsh neovim

# fonts
# source: https://github.com/ryanoasis/nerd-fonts
# Option 6
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
