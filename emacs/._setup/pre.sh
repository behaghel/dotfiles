#!/bin/bash

cd ~/install/git && git clone --depth 1 git://git.savannah.gnu.org/emacs.git
cd emacs
# ensure at least one deb-src in /etc/apt/sources.list
sudo apt-get build-dep emacs
./autogen.sh
./configure CFLAGS='-O3'
make
sudo make install
make clean
