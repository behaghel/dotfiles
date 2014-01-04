export EDITOR=vim
# useful in Emacs (eg auto-insert for .el)
export ORGANIZATION="Hubert Behaghel"

if $(which rbenv > /dev/null); then eval "$(rbenv init -)"; fi

# need to be at the end to update the full PATH
if [ -e ~/etc/profile ]; then
  source ~/etc/profile
fi
