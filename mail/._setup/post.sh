#!/bin/bash

# not stowed but copied as the copy stores the auth token which
# I can't afford to see accidentally coming into github...
cp ~/ws/dotfiles/mail/davmail.base.properties ~/.config/davmail.properties

cd ~/install/git/mu
./autogen.sh && make && sudo make install

mu init --my-address=hubert.behaghel@sky.uk --my-address=hubert.behaghel@bskyb.com --my-address=behaghel@gmail.com --my-address=hubert@behaghel.org --my-address=hubert@behaghel.fr -m ~/Maildir
