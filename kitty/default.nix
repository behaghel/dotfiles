{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.kitty;
in {
  options.hub.kitty = {
    enable = mkOption {
      description = "Enable kitty";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs = {
      kitty = {
        enable = true; # see https://github.com/NixOS/nixpkgs/pull/137512
        settings = {
          font_size = (if pkgs.stdenv.isDarwin then 14 else 12);
          strip_trailing_spaces = "smart";
          enable_audio_bell = "no";
          term = "xterm-256color";
          macos_titlebar_color = "background";
          macos_option_as_alt = "yes";
          scrollback_lines = 10000;
        };
        font = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
      };
    };
  };
}
