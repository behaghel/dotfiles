#!/bin/bash

set -e

cd $HOME/install/git/emacs
sudo=''
if (( $EUID != 0 )); then
    sudo='sudo'
fi
# ensure at least one deb-src in /etc/apt/sources.list
# $sudo sed -i '/deb-src/s/^# //' /etc/apt/sources.list && $sudo apt update
$sudo apt-get -y build-dep emacs
./autogen.sh
./configure CFLAGS='-O3'
make
$sudo make install
make clean

local_fonts_dir=$HOME/.local/share/fonts
iosevka_version=3.6.1
hasklig_version=1.1
jetbrainsmono_version=2.001
fonts=(
https://github.com/be5invis/Iosevka/releases/download/v$iosevka_version/ttf-iosevka-$iosevka_version.zip
https://github.com/i-tu/Hasklig/releases/download/$hasklig_version/Hasklig-$hasklig_version.zip
https://download.jetbrains.com/fonts/JetBrainsMono-$jetbrainsmono_version.zip
)
mkdir -p $local_fonts_dir 2> /dev/null
cd $local_fonts_dir
# install apps available to local users and root
for font in ${fonts[@]}; do
  wget $font
  unzip $(basename $font)
  rm $(basename $font)
done

# next follow https://wiki.debian.org/Exim4Gmail
# org capture with grasp
cd ~/install/git/grasp
[[ $has_systemd -eq 0 ]] && server/setup --path $HOME/Dropbox/Documents/org/inbox.org  --template "\n** %U [[%:link][%:description]] %:tags
%:selection
*** Comment
%:comment"
