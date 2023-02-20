{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.nix;
in {
  options.hub.nix = {
    lorri = mkOption {
      description = "Enable lorri";
      type = types.bool;
      default = false;
    };
  };

  config = {
    home.file.".config/nixpkgs/config.nix".source = ./.config/nixpkgs/config.nix;
    home.file.".config/nix/nix.conf".source = ./.config/nix/nix.conf;
    # TODO: only if cfg.lorri is true
    # services.lorri.enable = true;
  };
}
