{ config, pkgs, ... }:

{
  imports = [
    ../../../bash
    ../../../zsh
    ../../../git
    ../../../mail
    ../../../weechat
    ../../../nix
  ];

  config = {
    nixpkgs.config = import ./config.nix;
    home = {
      username = "hubertbehaghel";
      homeDirectory = "/home/hubertbehaghel";
      stateVersion = "22.05";
      packages = with pkgs; [
        kitty
        firefox
      ];
    };
    hub = {
      git.enable = true;
      mail.enable = true;
      # desktop.enable = false;
      nix.lorri = false;
      weechat.enable = false;
    };
    programs = {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;
    };

    services.dropbox.enable = true;
    services.dunst.enable = true;
  };
}
