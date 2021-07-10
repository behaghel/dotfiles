#!/usr/bin/env bash
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   DOTFILES_DIR=$HOME/.config/dotfiles sh install.sh
#
# Dependencies:
#   - git must be installed with your SSH keys in place for checking
#     out your dotfiles
#
# Respects the following environment variables:
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   DOTFILES_DIR  - path to the dotfiles dir
#   DOTFILES_REPO - origin of the dotfiles git repository
#   DOTFILES_PRETEND - if not empty will not modify the system
#
set -e

source $(dirname $0)/setup.sh

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
