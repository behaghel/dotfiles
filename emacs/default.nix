{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.emacs;
in {
  options.hub.emacs = {
    enable = mkOption {
      description = "Enable emacs";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs.emacs.enable = true;
    home.activation = {
      # git submodules don't work with home.file (they are empty)
      linkEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  $DRY_RUN_CMD ln -sf .dotfiles/emacs/.emacs.d
      '';
    };
  };
}
