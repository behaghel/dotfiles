#!/bin/bash

cd ~/.local/share/fonts
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

cd ~/install/git/mu
./autogen.sh && make && sudo make install

mu init --my-address=hubert.behaghel@sky.uk --my-address=hubert.behaghel@bskyb.com --my-address=behaghel@gmail.com --my-address=hubert@behaghel.org --my-address=hubert@behaghel.fr -m ~/Maildir

# next follow https://wiki.debian.org/Exim4Gmail
# org capture with grasp
cd ~/install/git/grasp
server/setup --path /home/behaghel/Dropbox/Documents/org/inbox.org  --template "\n** %U [[%:link][%:description]] %:tags
%:selection
*** Comment
%:comment"
