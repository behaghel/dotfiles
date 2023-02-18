{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.alacritty;
in {
  options.hub.alacritty = {
    enable = mkOption {
      description = "Enable alacritty";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          # to make Option (alt) work on macOS
          alt_send_esc = false;
          mouse_bindings = [{ mouse = "Middle"; action = "PasteSelection";}];
          font = {
            size = 15; # 14 creates glitches on p10k prompt
            normal.family = "MesloLGS NF"; # p10k recommends
          };
        };
      };
    };
  };
}
