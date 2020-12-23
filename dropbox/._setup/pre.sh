#!/bin/bash

# PRE
# file in this sequence will be extracted into $HOME
cd ~ && wget -O - https://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf -
cd ~/bin && curl -LO https://www.dropbox.com/download\?dl\=packages/dropbox.py && chmod +x dropbox.py

