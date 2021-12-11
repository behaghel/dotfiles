{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.nix;
in {
  options.hub.nix = {
    lorri = mkOption {
      description = "Enable nix";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.lorri) {
    services.lorri.enable = true;
  };
}
