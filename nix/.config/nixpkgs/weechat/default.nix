{ config, pkgs, ... }:

let
  # weechat-matrix broken in stable: can't find matrix_helper_sso
  # still broken in unstable but less so: it now wants me to identify
  # myself only through facebook/google/...
  weechat-matrix = pkgs.python3Packages.callPackage <nixos-unstable/pkgs/applications/networking/irc/weechat/scripts/weechat-matrix> {};
  weechat = pkgs.weechat.override { configure = { availablePlugins, ... }: {
    plugins = with availablePlugins; [
        # PodParser for Pod::Select.pm for menu.pl for spell suggestions
        (perl.withPackages (p: [ p.PodParser ]))
        # websocket_client for wee-slack and dbus-python for notifications
        (python.withPackages (ps: with ps; [ websocket_client dbus-python ]))
      ];
    scripts = [ weechat-matrix ];
    };
  };
in {
  home.packages = with pkgs; [
    weechat
    # weechat deps
    aspell aspellDicts.en aspellDicts.fr
    emojione
    libnotify
  ];
}
