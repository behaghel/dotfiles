#!/usr/bin/env bash

set -e

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv latest install -s
pyenv latest global # || true # tend to leave in a state of error

py_version=$(pyenv latest --print)
py_venv="dotfiles_venv$py_version"
pyenv virtualenv $py_version $py_venv
pyenv local $py_venv
pyenv activate $py_venv

pip install --upgrade pip
