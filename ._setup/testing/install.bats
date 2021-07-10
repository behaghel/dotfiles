#!/usr/bin/env ./libs/bats-core/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

profile_script="../../install.sh"

@test "install_package can take a list" {
  source ${profile_script}
  playbook() {
    # xargs trims whitespace
    tail -n 3 $1 | sed 's/^ \+- //' | tr '\n' ' ' | xargs
  }
  export -f playbook
  silent=true
  local result
  result=$(install_package a b c)
  # echo "'" "$result" "'"
  [ "$result" == "a b c" ]
}

@test "read_list_from_file handles in-line comment" {
  source ${profile_script}
  local result
  result=$(read_list_from_file ./data/needs_inline_comments | xargs)
  echo "'""$result""'"
  [ "$result" == "a b c" ]
}

@test "is_ability detects abilities" {
  source ${profile_script}
  export DOTFILES_DIR=./data/dotfiles_for_test_1
  is_ability "package"
}

@test "is_ability rejects non-abilities" {
  source ${profile_script}
  export DOTFILES_DIR=./data/dotfiles_for_test_1
  [ -z $(is_ability "a") ]
}

@test "prepit handles multiple dependencies" {
  source ${profile_script}
  playbook() {
    # xargs trims whitespace
    tail -n 3 $1 | sed 's/^ \+- //' | tr '\n' ' ' | xargs
  }
  export -f playbook
  export DOTFILES_DIR=./data/dotfiles_for_test_1
  local result
  result=$(install_deps "package")
  echo "'""$result""'"
  [ "$result" == "a b c" ]
}
