{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.pass;
in {
  options.hub.pass = {
    enable = mkOption {
      description = "Enable pass";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs = {
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
        };
      };
    };
    home.activation = {
      # git submodules don't work with home.file (they are empty)
      linkPasswordStore = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  $DRY_RUN_CMD ln -sf .dotfiles/pass/.password-store
      '';
    };
  };
}
