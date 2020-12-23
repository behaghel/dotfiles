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

# next follow https://wiki.debian.org/Exim4Gmail
# org capture with grasp
has_systemd=$([ $(command -v systemctl) ] && systemctl > /dev/null 2>&1; echo $?)
[[ $has_systemd -eq 0 ]] && cd ~/install/git/grasp && \
  server/setup --path $HOME/Dropbox/Documents/org/inbox.org\
               --template "\n** %U [[%:link][%:description]] %:tags
%:selection
*** Comment
%:comment"
