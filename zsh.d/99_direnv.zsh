eval "$(direnv hook zsh)"

## Python ##
# by default PS1 cannot be modified by direnv:
### https://github.com/direnv/direnv/wiki/PS1
# stolen from https://github.com/direnv/direnv/wiki/Python#zsh
# allow PS1 to show virtual env
show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
