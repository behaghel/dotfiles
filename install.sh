#!/bin/sh
# this is a very basic script:
#   no uninstall
#   no partial install (eg without oh-my-zsh)


for i in `cat .tobedotlinked`; do
  ln -s $PWD/$i ~/.$i
done

# oh-my-zsh
#wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh


