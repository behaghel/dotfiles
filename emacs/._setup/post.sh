#!/usr/bin/env bash

set -e

# next follow https://wiki.debian.org/Exim4Gmail
# org capture with grasp
has_systemd=$([ $(command -v systemctl) ] && systemctl > /dev/null 2>&1; echo $?)
[[ $has_systemd -eq 0 ]] && cd ~/install/git/grasp && \
  server/setup --path $HOME/Dropbox/Documents/org/inbox.org\
               --template "\n** %U [[%:link][%:description]] %:tags
%:selection
*** Comment
%:comment"
