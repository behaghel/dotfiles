export EDITOR=vim
# otherwise if set say to nano, that will be used by git
export VISUAL=vim

# useful in Emacs (eg auto-insert for .el)
export ORGANIZATION="Hubert Behaghel"

if $(which rbenv > /dev/null); then eval "$(rbenv init -)"; fi

# need to be at the end to update the full PATH
if [ -e ~/etc/profile ]; then
  source ~/etc/profile
fi
# set PATH to include cabal (Haskell) executables if it exists
if [ -d "$HOME/.cabal/bin" ] ; then
    PATH="$HOME/.cabal/bin:$PATH"
fi
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

