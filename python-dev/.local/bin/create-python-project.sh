#!/usr/bin/env bash

set -e
[ $# -ne 1 ] && echo "no arg: we need a name for your project" && return 4

project_name="$1"
project_slug=$(echo "$project_name" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/_/g | sed -r s/^_+\|_+$//g | tr A-Z a-z)

cd ~/ws

pyenv virtualenv $(pyenv latest --print) "$project_slug"

cookiecutter https://github.com/audreyfeldroy/cookiecutter-pypackage.git "project_name=$project_name" "project_slug=$project_slug"
cd "$project_slug"
pyenv local "$project_slug"
# pip install --upgrade pip # to stop the warning

git init .
git add .
git commit -m "Initial commit :sunrise:"

pip install -r requirements_dev.txt

pytest
