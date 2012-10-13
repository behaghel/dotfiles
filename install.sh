#!/bin/sh
# this is a very basic script:
#   no uninstall
#   no partial install (eg without oh-my-zsh)
#   need to be run from local dir


for i in `cat .tobedotlinked`; do
  ln -s $PWD/$i ~/.$i
done

# oh-my-zsh XXX not useful since we embed my full zshrc.
#wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

# vim
# uncomment if you want vim-plugins. requires git. TODO make it an option with getopts.
#mkdir ~/.vim-plugins
#cd ~/.vim-plugins
#git clone git://github.com/MarcWeber/vim-addon-manager.git
#cd ~
#git clone git://github.com/behaghel/.vim.git



