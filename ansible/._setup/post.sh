#!/bin/bash

# ensure python profile is loaded
source ~/.config/profile.d/python.profile 2> /dev/null

python -m pip install --user ansible
