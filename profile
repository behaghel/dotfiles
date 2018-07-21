export EDITOR=vim
# otherwise if set say to nano, that will be used by git
export VISUAL=vim

# useful in Emacs (eg auto-insert for .el)
export ORGANIZATION="Hubert Behaghel"

# need to be at the end to update the full PATH
if [ -e ~/etc/profile ]; then
  source ~/etc/profile
fi
