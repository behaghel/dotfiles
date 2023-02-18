{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.tex;
in {
  options.hub.tex = {
    enable = mkOption {
      description = "Enable tex";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs = {
      texlive = {
        enable = true;
        extraPackages =  tpkgs: { inherit (tpkgs) scheme-basic wrapfig amsmath ulem hyperref capt-of xcolor dvisvgm dvipng metafont; };
      };
    };
  };
}
