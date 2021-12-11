{ pkgs, config, lib, ... }:

{
  imports = [
    ./bash
    ./zsh
    ./git
    ./weechat
    ./X
    ./dropbox
    ./nix
  ];
}
