#!/usr/bin/env bash

# we don't provide our own ~/.profile as systems tend to have their
# own …and you never know
echo "for i in $HOME/.config/profile.d/*.profile; do source $i; done" >> ~/.profile