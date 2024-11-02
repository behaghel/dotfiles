{ pkgs, config, lib, ... }:
with lib;

# TODO: it's not really bash, it's shell, a precursor to any shell env
# currently if I enable my zsh module without this, it breaks it
let
  cfg = config.hub.firefox;
in {
  options.hub.firefox = {
    enable = mkOption {
      description = "Enable firefox";
      type = types.bool;
      default = true;           # TODO: I don't think we support false
    };
  };

  config = mkIf (cfg.enable) {
    programs = {
      firefox = {
        enable = true;
        profiles =
          let settings = {
                "app.update.auto" = true;
                # no top tabs => tabcenter on the side
                "browser.tabs.inTitlebar" = 0;
                # reopen windows and tabs on startup
                "browser.startup.page" = 3;
                extensions = with config.nur.repos.rycee.firefox-addons; [
                  ublock-origin
                  browserpass
                  org-capture
                  pinboard
                  vimium
                  duckduckgo-privacy-essentials
                  kristofferhagen-nord-theme
                ];

              };
          in {
            home = {
              id = 0;
              inherit settings;
            };
            work = {
              id = 1;
              settings = settings // {
                "extensions.activeThemeID" = "nord-theme";
              };
            };
          };
      };
      browserpass = {
        enable = true;
        browsers = [ "firefox" "brave" ];
      };
    };
  };
}
