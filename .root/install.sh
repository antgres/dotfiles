#########
# Script for


# install font for tree
# https://github.com/ryanoasis/nerd-fonts#option-6-ad-hoc-curl-download


if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID

    if [[ $OS == *"Debian"* ]]; then
        OS="Debian"
    fi
fi
echo "$OS, $VER"


