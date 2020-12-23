#!/bin/bash

set -e

DIR=$(dirname "$0")

pkgs=( $(read_list_from_file $DIR/pipx.txt) )
for pkg in "${pkgs[@]}"; do
    pipx install $pkg
done
