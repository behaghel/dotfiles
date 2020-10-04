#!/usr/bin/env bash
set -e

#FIXME: delete next line when ready
DOTFILES_DEBUG=${DOTFILES_DEBUG:-true}
DOTFILES_DIR=${DOTFILES_DIR:-~/.dotfiles}
DOTFILES_REPO=${DOTFILES_REPO:-git@github.com:behaghel/dotfiles.git}
BRANCH=${BRANCH:-master}
setup_dir_name="._setup"

[ -n "$DOTFILES_DEBUG" ] && set -x

command_exists() {
  command -v "$@" >> /dev/null 2»&1
}

failed_checkout() {
  echo "Failed to git clone $1"
  exit -1
}

checkout() {
  [ -d "$2" ] || git clone --branch "$BRANCH" "$1" "$2" || failed_checkout "$1"
}

run_if_exists() {
  [ -x $1 ] && ($DOTFILES_DEBUG && echo "Simulation: $1" || $1) || \
    true # stay truthy even when no executable was run
}

run_hook() {
  local capability=$1
  local hook=$2
  run_if_exists $DOTFILES_DIR/$capability/$setup_dir_name/$hook.sh
}

bootstrap(){
  command_exists git || {
    # TODO: try to eat your own dog food and install git
    error "git is not installed"
    exit 1
  }

  checkout $DOTFILES_REPO $DOTFILES_DIR
  run_hook "." "pre"
}

read_list_from_file() {
  # allow several item on one line (sep by space) and allow commenting out a line with #
  cat $1 | egrep -v '^#' | sed 's/ /\n/g'
}

is_ability() {
  # TODO: ankify find
  capabilities=$(find $DOTFILES_DIR -maxdepth 1 -type d -not \( -name "$(basename $DOTFILES_DIR)" -o -name "$setup_dir_name" -o -name ".*" \) -exec basename {} ';')
  # TODO: ankify bash tests and array membership and predicate functions
  [[ $capabilities[@] =~ "$1" ]]
}

prepit() {
  echo "prepping $1..."
  needs=$DOTFILES_DIR/$1/$setup_dir_name/needs
  [ -f $needs ] && \
    local deps=( $(read_list_from_file $needs) ) && \
    installit $deps
  #FIXME: if the ability has the same name as one of its dependencies, then infinite loop => force package_install in that scenario

  run_hook $1 "pre"
  echo "$1 prepped."
}

stowit() {
    # -v verbose
    # -n DOTFILES_DEBUG but don't do anything
    # -R recursive
    # -t target
    stow -v${DOTFILES_DEBUG:+ -n} -R -t ${HOME} --ignore ${setup_dir_name} $1
}

wrapit() {
  echo "wrapping for $1..."
  run_hook $1 "post"
  echo "$1 is ready."
}

package_install() {
  apps=$@
  echo "install package $apps"
  #TODO: implement me through either brew or ansible
  # remember to handle "DOTFILES_DEBUG" flag
}

installit() {
  #TODO: allow to pass a list of names
  # that means figuring out dependencies and potentially cycles
  # that means reusing a package manager: either ansible or brew even for abilities
  echo "install $1..."

  is_ability $1 && \
    #TODO: unless already installed
    prepit $1 && \
    stowit $1 && \
    wrapit $1
  is_ability $1 || package_install $1
}

bootstrap && installit "$@"
