{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.dropbox;
in {
  options.hub.dropbox = {
    enable = mkOption {
      description = "Enable dropbox";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.dropbox.enable = true;
  };
}
