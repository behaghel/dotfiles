export PATH="/home/behaghel/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(pyenv which python3)
export PROJECT_HOME=$HOME/ws
export pyenv_prefix=$(pyenv prefix)
[ -f $pyenv_prefix/bin/virtualenvwrapper.sh ] && \
    source $pyenv_prefix/bin/virtualenvwrapper.sh
[ -f ~/.local/bin/virtualenvwrapper.sh ] && \
    source ~/.local/bin/virtualenvwrapper.sh
