{ config, pkgs, ... }:

{
  imports = [
    ../../../bash
    ../../../zsh
    ../../../git
    ../../../pass
    ../../../mail
    ../../../weechat
    ../../../nix
    ../../../X
    ../../../kitty
    ../../../alacritty
    # ../../../tex
    ../../../firefox
  ];

  config = {
    nixpkgs.config = import ./config.nix;
    home = {
      username = "hubertbehaghel";
      homeDirectory = "/home/hubertbehaghel";
      stateVersion = "22.05";
    };
    hub = {
      git.enable = true;
      mail.enable = true;
      desktop.enable = false;
      desktop.notify = false;
      nix.lorri = false;
      weechat.enable = false;
    };
    programs = {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;
    };

    services.dropbox.enable = true;
  };
}
