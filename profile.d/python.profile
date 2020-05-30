export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(pyenv which python3)
export PROJECT_HOME=$HOME/ws
source $(pyenv prefix)/bin/virtualenvwrapper.sh

# zsh pyenv plugin does that already
# export PATH="/home/behaghel/.pyenv/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"
