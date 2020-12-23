export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# don't pollute my python install
export PIP_REQUIRE_VIRTUALENV=true
# unset to bypass: PIP_REQUIRE_VIRTUALENV="" pip install xxx

# export WORKON_HOME=$HOME/.virtualenvs
# export VIRTUALENVWRAPPER_PYTHON=$(pyenv which python3)
# export PROJECT_HOME=$HOME/ws
# export pyenv_prefix=$(pyenv prefix)
# [ -f $pyenv_prefix/bin/virtualenvwrapper.sh ] && \
#     source $pyenv_prefix/bin/virtualenvwrapper.sh
# [ -f ~/.local/bin/virtualenvwrapper.sh ] && \
#     source ~/.local/bin/virtualenvwrapper.sh
