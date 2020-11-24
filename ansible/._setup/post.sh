#!/bin/bash

source "$HOME"/.config/profile.d/*.profile 2> /dev/null

python -m pip install --user ansible
