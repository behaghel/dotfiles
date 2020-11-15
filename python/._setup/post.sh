#!/bin/bash

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

#pyenv install-latest
pyenv latest install -s
pyenv latest global || true # tend to leave in a state of error
