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
      default = "behaghel";
    };

    userEmail = mkOption {
      description = "user's email for git";
      type = types.str;
      default = "behaghel@gmail.com";
    };
  };

  config = mkIf (cfg.enable) {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      extraConfig = {
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      };
    };

    home.file.".gitconfig".source = ./.gitconfig;

    # pass-git-helper
    home.packages = with pkgs; [
      pass-git-helper
    ];
    xdg.configFile."pass-git-helper/git-pass-mapping.ini".source = .config/pass-git-helper/git-pass-mapping.ini;
  };
}
