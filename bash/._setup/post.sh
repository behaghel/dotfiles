#!/usr/bin/env bash

# we don't provide our own ~/.profile as systems tend to have their
# own …and you never know
#TODO: make it idempotent
echo 'for i in $HOME/.config/profile.d/*.profile; do source $i; done' >> ~/.bashrc
exec bash
