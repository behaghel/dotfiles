#!/bin/bash

cd $HOME/install/git/emacs
# ensure at least one deb-src in /etc/apt/sources.list
sudo apt-get build-dep emacs
./autogen.sh
./configure CFLAGS='-O3'
make
sudo make install
make clean

cd $HOME/.local/share/fonts
iosevka_version=3.6.1
hasklig_version=1.1
jetbrainsmono_version=2.001
fonts=(
https://github.com/be5invis/Iosevka/releases/download/v$iosevka_version/ttf-iosevka-$iosevka_version.zip
https://github.com/i-tu/Hasklig/releases/download/$hasklig_version/Hasklig-$hasklig_version.zip
https://download.jetbrains.com/fonts/JetBrainsMono-$jetbrains_version.zip
)
# install apps available to local users and root
for font in ${fonts[@]}; do
  wget $font
  unzip $(basename $font)
  rm $(basename $font)
done

# next follow https://wiki.debian.org/Exim4Gmail
# org capture with grasp
cd ~/install/git/grasp
server/setup --path $HOME/Dropbox/Documents/org/inbox.org  --template "\n** %U [[%:link][%:description]] %:tags
%:selection
*** Comment
%:comment"
