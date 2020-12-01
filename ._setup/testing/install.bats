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
