#!/usr/bin/env bash
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/behaghel/dotfiles/master/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/behaghel/dotfiles/master/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/behaghel/dotfiles/master/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/behaghel/dotfiles/master/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   DOTFILES_DIR=$HOME/.config/dotfiles sh install.sh
#
# Respects the following environment variables:
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   DOTFILES_DIR  - path to the dotfiles dir
#   DOTFILES_REPO - origin of the dotfiles git repository
#
#
set -e

#FIXME: delete next line when ready
#DOTFILES_DEBUG=${DOTFILES_DEBUG:-true}
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

is_ansible_role() {
  echo "$1" | awk -F: '$1 ~ "ansible" {print $2}'
}

prepit() {
  echo "prepping $1..."
  #TODO: allow for different dependencies on linux vs macos
  needs=$DOTFILES_DIR/$1/$setup_dir_name/needs
  [ -f $needs ] && \
    local deps=( $(read_list_from_file $needs) ) && \
    installit $deps $1

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

install_ansible() {
  command_exists ansible_galaxy || install_ability ansible
  ansible-galaxy install "$role"
  tmpfile=$(mktemp)
  echo "- hosts: all\n  roles:\n    - $role" >> "$tmpfile"
  # -K ask for sudo passwold
  # -b become sudo
  # -i [file] inventory (prepackage with only localhost)
  ansible-playbook -K -b -i $DOTFILES_DIR/._setup/ansible/hosts "$tmpfile"
  rm "$tmpfile"
}

install_package() {
  local apps=$@
  echo "install package $apps"
  #TODO: implement me through either brew or ansible
  # remember to handle "DOTFILES_DEBUG" flag
}

already_installed() {
  run_hook $1 "verify"
}

install_ability() {
  # for i in "${!1[@]}"; do
      already_installed $1 || \
          ( prepit $1 && \
                stowit $1 && \
                wrapit $1 )
  # done
}

installit() {
  [ -n $1 ] || exit -1 # nothing to install
  local instal_list=$1
  local requester=$2
  local abilities=()
  local ansible_roles=()
  local packages=()
  for i in "${!install_list[@]}"; do
    if [[ ${install_list[i]} = $1 ]]; then
      # ability $1 has a dependency of the same name, stop the infinite loop
      packages+=( $1 )
    elif [[ -n $(is_ansible_role ${install_list[i]}) ]]; then
      ansible_roles+=( $(is_ansible_role ${install_list[i]}) )
    elif [[ $(is_ability ${install_list[i]}) ]]; then
      abilities+=( ${install_list[i]} )
    else
      packages+=( ${install_list[i]} )
    fi
  done

  [[ ${#packages[@]} -gt 0 ]] && install_package ${packages[@]}
  [[ ${#ansible_roles[@]} -gt 0 ]] && install_ansible ${ansible_roles[@]}
  [[ ${#abilities[@]} -gt 0 ]] && install_ability ${abilities[@]}
  #TODO: ansible and packages XXX
  #btw we can't postpone / batch at the end because iteration will fail without their deps in place

  #FIXME: should be more elegant
  is_ability $1 && (install_ability $1 || exit -1) || install_package $1
}

bootstrap && [ $# -gt 0 ] && installit "$@"
