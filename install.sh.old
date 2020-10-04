#!/bin/sh
# this is a very basic script:
#   no uninstall
#   no partial install (eg without oh-my-zsh)
#   need to be run from local dir

user_cfg_dir=$HOME/.config

echo "the following should have been installed manually:"
echo "- https://github.com/ohmyzsh/ohmyzsh"
echo "- https://github.com/gpakosz/.tmux"

mkdir -p $user_cfg_dir

ln -s $PWD/profile.d $user_cfg_dir/profile.d 2> /dev/null
# TODO: automate this
echo "To load your shell environment, add the following to your .profile"
echo "source $HOME/.config/profile.d/*.profile"
ln -s $PWD/zsh.d $user_cfg_dir/zsh.d 2> /dev/null

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



