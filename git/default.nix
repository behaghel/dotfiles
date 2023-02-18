{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.git;
in {
  options.hub.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = false;
    };

    userName = mkOption {
      description = "user's name for git";
      type = types.str;
      default = "Hubert Behaghel";
    };

    userEmail = mkOption {
      description = "user's email for git";
      type = types.str;
      default = "behaghel@gmail.com";
    };

    github = mkOption {
      description = "Enable github tooling";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
    };

    home.file.".gitconfig".source = ./.gitconfig;

    home.packages = with pkgs; [
      gh              # TODO: condition this to github option above
    ];
    xdg.configFile."pass-git-helper/git-pass-mapping.ini".source = .config/pass-git-helper/git-pass-mapping.ini;
  };
}
