{ pkgs, config, lib, ... }:
with lib;

# TODO: it's not really bash, it's shell, a precursor to any shell env
# currently if I enable my zsh module without this, it breaks it
let
  cfg = config.hub.bash;
in {
  options.hub.bash = {
    enable = mkOption {
      description = "Enable bash";
      type = types.bool;
      default = true;           # TODO: I don't think we support false
    };

    direnv = mkOption {
      description = "Enable my direnv config";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    # TODO: DRY
    # technically that should look like
    # home.file.".config".source = ./.config;
    # home.file.".config".recursive = true;
    home.file.".lesskey".source = ./.lesskey;
    home.file.".ctags".source = ./.ctags;
    home.file.".aliases".source = ./.aliases;
    xdg.configFile."profile.d/hub.profile".source = ./.config/profile.d/hub.profile;
    xdg.configFile."profile.d/zz_path.profile".source = ./.config/profile.d/zz_path.profile;


    programs.direnv = {
      enable = cfg.direnv;
      enableZshIntegration = config.hub.zsh.enable;
      enableBashIntegration = config.hub.bash.enable;
      nix-direnv.enable = cfg.direnv;
    };
    xdg.configFile."direnv/direnvrc".source = ./.direnvrc;

    home.packages = with pkgs;
      let my-aspell = aspellWithDicts (ds: with ds; [en fr es]);
      in [
      neofetch
      pandoc
      wget
      my-aspell
    ];
  };
}
