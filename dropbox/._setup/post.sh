#!/bin/bash

# start dropboxd: dropbox.py start but from systemctl
# ~/.dropbox-dist/dropboxd # then wait for sync to complete
# excludes from dropbox content from exclude.dropbox

# POST
# dropbox.py exclude add $i
home_archives=(
    ssh2.tgz
    gpg.tgz
    )

for archive in ${home_archives[@]}; do
    tar xzvf ${HOME}/Dropbox/$archive -C ${HOME}
done
