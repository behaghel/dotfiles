#!/bin/bash

# set up ZSH
# APT update upgrade install list from install.apt goes here
export KEEP_ZSH=yes && export RUN_ZSH=no && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
