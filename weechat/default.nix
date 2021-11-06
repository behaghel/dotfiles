{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.weechat;
  # weechat-matrix broken in stable: can't find matrix_helper_sso
  # still broken in unstable but less so: it now wants me to identify
  # myself only through facebook/google/...
  # weechat-matrix = pkgs.python3Packages.callPackage <nixpkgs/pkgs/applications/networking/irc/weechat/scripts/weechat-matrix> {};
  weechat = pkgs.weechat.override { configure = { availablePlugins, ... }: {
    plugins = with availablePlugins; [
        # PodParser for Pod::Select.pm for menu.pl for spell suggestions
        (perl.withPackages (p: [ p.PodParser ]))
        # websocket_client for wee-slack and dbus-python for notifications
        # TODO: dbus-python if cfg.notify
        # TODO: websocket_client if cfg.slack
        (python.withPackages (ps: with ps; [ websocket_client dbus-python ]))
      ];
    # TODO: if cfg.weechat-matrix
    scripts = [ pkgs.weechatScripts.weechat-matrix ];
    };
  };
in {
  options.hub.weechat = {
    enable = mkOption {
      description = "Enable weechat";
      type = types.bool;
      default = false;
    };

    slack = mkOption {
      description = "Enable slack integration";
      type = types.bool;
      default = false;
    };

    matrix = mkOption {
      description = "Enable matrix.org integration";
      type = types.bool;
      default = false;
    };

    notify = mkOption {
      description = "Enable desktop notification (libnotify)";
      type = types.bool;
      default = false;
    };


  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
        weechat
        # weechat deps
        aspell aspellDicts.en aspellDicts.fr
        emojione
        # TODO: if cfg.notify
        libnotify
    ];
  };
}
