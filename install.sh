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

DOTFILES_DEBUG=${DOTFILES_DEBUG:-$DOTFILES_PRETEND}
DOTFILES_DIR=${DOTFILES_DIR:-~/.dotfiles}
DOTFILES_REPO=${DOTFILES_REPO:-git@github.com:behaghel/dotfiles.git}
BRANCH=${BRANCH:-master}
setup_dir_name="._setup"
[ -n "$DOTFILES_DEBUG" ] && set -x

log() {
    $silent || echo $@
}

command_exists() {
  command -v "$@" >> /dev/null 2>&1
}
export -f command_exists

restart_shell=""
abilities=$(find $DOTFILES_DIR -maxdepth 1 -type d -not \( -name "$(basename $DOTFILES_DIR)" -o -name "$setup_dir_name" -o -name ".*" \) -exec basename {} ';')
has_systemd=$([ $(command_exists systemctl) ] && systemctl; echo $?)

failed_checkout() {
  echo "Failed to git clone $1"
  exit -1
}

reload_context() {
  for i in "$HOME"/.config/profile.d/*.profile; do
    source $i
  done
}
export -f reload_context

checkout() {
  command_exists git || install_ability git
  git clone --branch "$BRANCH" "$1" "$2" || failed_checkout "$1"
}

run_if_exists() {
  if [ -x $1 ]; then
    ([ -n "$DOTFILES_PRETEND" -a "$2" != "verify" ] && echo "Simulation: $1") || $1
  else
    true # stay truthy even when no executable was run
  fi
}

hook_file() {
  echo "$DOTFILES_DIR/$1/$setup_dir_name/$2.sh"
}

run_hook() {
  local hook=$(hook_file $1 $2)
  if [ "$2" == 'verify' -a ! -x $hook ]; then
    command_exists $1 && echo "command $1 exists already"
    # default verification: check is command named like the ability exists
  else
    run_if_exists $hook $2
  fi
}

read_list_from_file() {
  # allow several item on one line (sep by space) and allow commenting out a line with #
  cat $1 | egrep -v '^#' | sed 's/[ \t]*#.*$//' | sed 's/ /\n/g'
}
export -f read_list_from_file

is_ability() {
  #TODO: ankify bash tests and array membership and predicate functions and find
  local re="\\b$1\\b"
  [[ "$abilities" =~ $re ]] && echo "$1"
}

is_ansible_role() {
  echo "$1" | awk -F: '$1 ~ "ansible" {print $2}'
}

install_deps() {
  #TODO: allow for different dependencies on linux vs macos
  local needs=$DOTFILES_DIR/$1/$setup_dir_name/needs
  [ -f $needs ] && \
    local deps=( $(read_list_from_file $needs) ) && \
    [ -n "$deps" ] && installit $1 "${deps[@]}"
}

install_fonts() {
  local fonts_file=$DOTFILES_DIR/$1/$setup_dir_name/fonts
  [ -f $fonts_file ] && \
    local fonts=( $(read_list_from_file $fonts_file) ) || return 0
  local_fonts_dir=$HOME/.local/share/fonts
  mkdir -p $local_fonts_dir 2> /dev/null
  cd $local_fonts_dir
  # install apps available to local users and root
  local font
  local font_url
  for font_url in ${fonts[@]}; do
    wget $font_url
    font=$(basename $font_url)
    [[ "$font" == *zip ]] && unzip $font
    rm $(basename $font)
  done
}

prepit() {
  ( [ "$1" == "." ] || git submodule update --init "$1" )
  install_deps $1
  install_fonts $1
  run_hook $1 "pre"
}

stowit() {
  # -v verbose
  # -n DOTFILES_PRETEND but don't do anything
  # -R recursive
  # -t target
  # we treat "." as an ability but we don't stow it for obvious reasons
  [ "$1" == "." ] || \
    stow -v${DOTFILES_PRETEND:+ -n} -R -t ${HOME} --no-folding --ignore ${setup_dir_name} $1
}

wrapit() {
  # if $DOTFILES_DIR/$1/.config/profile.d/ not empty, then reload shell
  [ -d "$DOTFILES_DIR/$1/.config/profile.d/" ] && \
    reload_context && restart_shell=true
  provides=$DOTFILES_DIR/$1/$setup_dir_name/provides
  [ -f $provides ] && [ $has_systemd -eq 0 ] &&\
    local services=( $(read_list_from_file $provides) ) && \
    systemctl --user daemon-reload && \
    for service in ${services[@]}; do
      if [ -z "$DOTFILES_PRETEND" ]; then
        systemctl --user enable $service
        systemctl --user start $service
      else
        echo "Simulation: activation of $service through systemctl"
      fi
    done
  run_hook $1 "post" || exit -5
  echo "$1 is ready."
}

ensure_ansible() {
  command_exists ansible-playbook || {
    install_ability ansible && reload_context
  }
}

playbook() {
  ensure_ansible
  # -K ask for sudo password
  # -b become sudo
  # -i [file] inventory (prepackage with only localhost)
  ansible-playbook -K -b${DOTFILES_PRETEND:+ --syntax-check} -i $DOTFILES_DIR/._setup/ansible/hosts "$1" && rm "$1"
}

install_ansible() {
  ensure_ansible
  tmpfile=$(mktemp)
  echo -ne "---\n- hosts: all\n  roles:\n" >> "$tmpfile"
  for role in "${1[@]}"; do
    ansible-galaxy install "$role"
    echo "    - $role" >> "$tmpfile"
  done
  playbook "$tmpfile"
}

install_package() {
  local apps=$@
  local i
  log "install package $apps"
  tmpfile=$(mktemp)
  echo -ne "---\n- hosts: all\n  tasks:\n    - name: Install $apps\n      package:\n        state: present\n        name:\n" >> "$tmpfile"
  for i in $@; do
    echo "          - $i" >> "$tmpfile"
  done
  playbook "$tmpfile"
}

noop() {
  echo "nothing to install";
  exit -1;
}

install_ability() {
  local abis=( $@ )
  [ ${#abis[@]} -gt 0 ] || noop
  local i
  for i in "${abis[@]}"; do
    run_hook $i "verify" || {
      prepit $i && stowit $i && wrapit $i;
    }
  done
}

installit() {
  [ -n $1 ] || noop
  local requester=$1
  shift
  local install_list=( "$@" )
  local abilities_to_install=()
  local ansible_roles=()
  local packages=()
  local i
  for i in "${install_list[@]}"; do
    local ansible_role=$(is_ansible_role $i)
    local ability=$(is_ability $i)
    if [[ $i = $requester ]]; then
      # ability $1 has a dependency of the same name, stop the infinite loop
      packages+=( $requester )
    elif [ -n "$ansible_role" ]; then
      ansible_roles+=( $ansible_role )
    elif [ -n "$ability" ]; then
      abilities_to_install+=( $ability )
    else
      packages+=( $i )
    fi
  done

  [[ ${#ansible_roles[@]} -gt 0 ]] && install_ansible ${ansible_roles[@]}
  [[ ${#abilities_to_install[@]} -gt 0 ]] && install_ability ${abilities_to_install[@]}
  [[ ${#packages[@]} -gt 0 ]] && install_package ${packages[@]}
}

main(){
  #install_ability "." &&
  [ $# -gt 0 ] && installit '_root_' "$@"
  #TODO: have a help printed when no arguments
  #FIXME: restart_shell seems to get set in a subshell…
  # indeed one level of {} doesn't create subshell but any deeper
  # level will… unbelievable
  [ -n "$restart_shell" ] && \
    echo "Restarting $SHELL to update config..." && \
    exec $SHELL
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
