#!/usr/bin/env bash

# set up ZSH
export KEEP_ZSH=yes && export RUNZSH=no && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv $HOME/.zshrc $HOME/.zshrc.oh-my-zsh.orig
