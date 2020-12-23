#!/bin/bash
# lots of inspiration coming from this good fellow:
# https://medium.com/analytics-vidhya/my-python-development-and-daily-usage-setup-af8633ddef78
set -e

DIR=$(dirname "$0")

plugins=$(read_list_from_file "$DIR"/pyenv-plugins)
for plugin in "${plugins[@]}"; do
  plugin_name=$(echo $plugin | cut -d '/' -f2)
  plugin_dir=$(pyenv root)/plugins/$plugin_name
  [[ -d $plugin_dir ]] && rm -rf "$plugin_dir"
  git clone https://github.com/$plugin "$plugin_dir"
done

pip3 install --user pipx
