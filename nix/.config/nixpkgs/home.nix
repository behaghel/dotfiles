{ config, pkgs, ... }:

{
  nixpkgs.config = import ./config.nix;
  imports = [
    ./zsh.nix
    ./weechat
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # TODO: DRY
  # technically that should look like
  # home.file.".config".source = ../../../bash/.config;
  # home.file.".config".recursive = true;
  home.file.".gitconfig".source = ../../../bash/.gitconfig;
  home.file.".lesskey".source = ../../../bash/.lesskey;
  home.file.".ctags".source = ../../../bash/.ctags;
  home.file.".aliases".source = ../../../bash/.aliases;
  xdg.configFile."profile.d/hub.profile".source = ../../../bash/.config/profile.d/hub.profile;
  xdg.configFile."profile.d/zz_path.profile".source = ../../../bash/.config/profile.d/zz_path.profile;

  home.packages = with pkgs; [
    kitty
    firefox
  ];

  # required for nix, nix.el, lorri, python…
  programs.direnv = {
    enable = true;
    # enableNixDirenvIntegration = true;
  };
  xdg.configFile."direnv/direnvrc".source = ../../../bash/.direnvrc;

  services.dropbox.enable = true;
  services.dunst.enable = true;

  # https://github.com/nix-community/lorri
  services.lorri.enable = true;
}
