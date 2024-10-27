{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.gpg;
in {
  options.hub.gpg = {
    enable = mkOption {
      description = "Enable gpg";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs.gpg = {
      enable = true;
      settings = {
        # Your gpg.conf settings here if needed
      };
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      grabKeyboardAndMouse = true;
      enableScDaemon = false;
      pinentryPackage = null;
      # pinentryFlavor = "curses";  # or "qt" for GUI
      # Additional gpg-agent settings if needed
      extraConfig = ''
      allow-preset-passphrase
      allow-loopback-pinentry
      allow-emacs-pinentry
      # to retrieve passphrase from system keyring via fingerprint
      pinentry-program ${config.home.homeDirectory}/.local/bin/pinentry-biometric
    '';
    };
    home.packages = with pkgs; [
      pinentry-curses
    ];
  };
}
