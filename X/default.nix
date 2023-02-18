{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.desktop;
in {
  options.hub.desktop = {
    enable = mkOption {
      description = "Enable desktop";
      type = types.bool;
      default = false;
    };
    notify = mkOption {
      description = "enable notifications";
      type = types.bool;
      default = true;
    };

  };

  config = mkIf (cfg.enable) {
    services.dunst = mkIf (cfg.notify) {
      enable = true;
    };
  };
}
