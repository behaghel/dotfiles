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
  command -v "$@" >> /dev/null 2>&1
}

failed_checkout() {
  echo "Failed to git clone $1"
  exit -1
}

checkout() {
  git clone --branch "$BRANCH" "$1" "$2" || failed_checkout "$1"
}

run_if_exists() {
  if [ -x $1 ]; then
    [ -n "$DOTFILES_DEBUG" ] && echo "Simulation: $1" || $1
  else
    true # stay truthy even when no executable was run
  fi
}

hook_file() {
  echo "$DOTFILES_DIR/$1/$setup_dir_name/$2.sh"
}

run_hook() {
  local hook=$(hook_file $1 $2)
  run_if_exists $hook
  if [ "$2" == 'verify' -a ! -x $hook ]; then
    command_exists $1 && echo "command $1 exists already"
    # default verification: check is command named like the ability exists
  fi
}

bootstrap(){
  command_exists git || {
    # TODO: try to eat your own dog food and install git
    error "git is not installed"
    exit 1
  }

  [ -d "$DOTFILES_DIR" ] || (checkout $DOTFILES_REPO $DOTFILES_DIR && \
    run_hook "." "pre")
}

read_list_from_file() {
  # allow several item on one line (sep by space) and allow commenting out a line with #
  cat $1 | egrep -v '^#' | sed 's/ /\n/g'
}

is_ability() {
  #TODO: ankify bash tests and array membership and predicate functions and find
  #FIXME: why can't I lazy initialise abilities in another function?
  abilities=$(find $DOTFILES_DIR -maxdepth 1 -type d -not \( -name "$(basename $DOTFILES_DIR)" -o -name "$setup_dir_name" -o -name ".*" \) -exec basename {} ';')
  [[ $abilities[@] =~ "$1" ]]
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
  local apps=$@
  echo "install package $apps"
  #TODO: implement me through either brew or ansible
  # remember to handle "DOTFILES_DEBUG" flag
}

already_installed() {
  run_hook $1 "verify"
}

install_ability() {
  already_installed $1 || \
    ( prepit $1 && \
    stowit $1 && \
    wrapit $1 )
}

installit() {
  #TODO: allow to pass a list of names
  # that means figuring out dependencies and potentially cycles
  # that means reusing a package manager: either ansible or brew even for abilities
  # also, fail if $1 is empty / undefined
  echo "install $1..."

  #FIXME: should be more elegant
  is_ability $1 && (install_ability $1 || exit -1) || package_install $1
}

bootstrap && [ $# -gt 0 ] && installit "$@"
