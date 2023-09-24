{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
# for configurable nixos modules see (note that many of them might be linux-only):
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/module-list.nix
#
# for configurable nix-darwin modules see
# https://github.com/LnL7/nix-darwin/blob/master/modules/module-list.nix
{
  environment.systemPackages = with pkgs; [nixVersions.stable];
  nixpkgs.overlays = [
    (import ./../overlay.nix)
    inputs.darwin-emacs.overlays.emacs

    (self: super: {
      # https://github.com/nmattia/niv/issues/332#issuecomment-958449218
      niv =
        self.haskell.lib.compose.overrideCabal
          (drv: { enableSeparateBinOutput = false; })
          super.haskellPackages.niv;
    })
  ];
  nix.settings = {
    substituters = [
      "https://cachix.org/api/v1/cache/emacs"
    ];
    trusted-public-keys = [
      "emacs.cachix.org-1:b1SMJNLY/mZF6GxQE+eDBeps7WnkT0Po55TAyzwOxTY="
    ];
  };
  imports = [
    ./../darwin/system.nix

    ({ pkgs, lib, ... }: {
      # Fonts
      fonts = {
        fonts = with pkgs; [
          # fonts that many things (apps, websites) expect
          dejavu_fonts
          liberation_ttf
          roboto
          raleway
          ubuntu_font_family
          # unfree
          # corefonts
          # helvetica-neue-lt-std
          # fonts I use
          etBook
          emacs-all-the-icons-fonts
          # coding fonts
          source-sans-pro
          source-serif-pro
          (nerdfonts.override {
            enableWindowsFonts = true;
            fonts = [ "Iosevka" "FiraCode" "Hack" "Inconsolata" "JetBrainsMono" "Hasklig" "Meslo" "Noto" ];
          })
          font-awesome
        ];
        # the modern way in NixOS: fontDir.enable = true;
        fontDir.enable = true;
      };

      # System / General
      # Recreate /run/current-system symlink after boot
      services.activate-system.enable = true;
    })


    ./../darwin/yabai.nix
    # ./../services/sketchybar
    ./../darwin/sketchybar
    ./../darwin/skhd

  ];
}
