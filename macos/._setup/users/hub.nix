{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../../bash # FIXME: has to be here for ./zsh to work
    ../../../zsh
    ../../../git
    ../../../pass
    ../../../mail
    ../../../weechat
    ../../../kitty
    ../../../alacritty
    ../../../tex
    ../../../firefox
  ];

  config =  {
    hub = {
      git.enable = true;
      mail.enable = true;
      desktop.enable = false;
      nix.lorri = false;
      weechat.enable = false;
    };

    home.packages = with pkgs;
      [
        # macos only
        terminal-notifier
        coreutils
        # dmg through niv
        niv # Broken on darwin: https://github.com/NixOS/nixpkgs/issues/140774
        #nivApps.Dropbox
        nivApps.Anki
        nivApps.VLC
        nivApps.Zotero
        nivApps.Kindle
      ];

    programs = {
      dircolors = {
        enable = true;
      };
      git = {
        enable = true;
        userName = "Hubert Behaghel";
        userEmail = "behaghel@gmail.com";
      };
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
        };
      };
      firefox = {
        package = pkgs.nivApps.Firefox;
        profiles =
          let settings = {
                "app.update.auto" = true;
                # no top tabs => tabcenter on the side
                "browser.tabs.inTitlebar" = 0;
                # reopen windows and tabs on startup
                "browser.startup.page" = 3;
              };
              extensions = with config.nur.repos.rycee.firefox-addons; [
                ublock-origin
                browserpass
                org-capture
                pinboard
                vimium
                duckduckgo-privacy-essentials
              ];
          in {
            home = {
              id = 0;
              inherit settings extensions;
            };
            work2 = {
              id = 1;
              settings = settings // {
                "extensions.activeThemeID" = "cheers-bold-colorway@mozilla.org";
              };
              inherit extensions;
            };
          };
      };
      emacs = {
        package = pkgs.emacs;
      };
      kitty = {
        enable = true; # see https://github.com/NixOS/nixpkgs/pull/137512
        settings = {
          font_size = (if pkgs.stdenv.isDarwin then 14 else 12);
          strip_trailing_spaces = "smart";
          enable_audio_bell = "no";
          term = "xterm-256color";
          macos_titlebar_color = "background";
          macos_option_as_alt = "left";
          scrollback_lines = 10000;
          scrollback_pager = "less +G -R";
        };
        font = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
        keybindings = {
          "alt+space" = "_";
          "alt+y" = "{";
          "alt+x" = "}";
          "alt+è" = "`";
        };
        extraConfig = ''
        mouse_map left click ungrabbed mouse_handle_click selection link prompt
        mouse_map ctrl+left press ungrabbed,grabbed mouse_click_url
        '';
      };
      alacritty = {
        enable = true;
        settings = {
          # to make Option (alt) work on macOS
          alt_send_esc = false;
          mouse_bindings = [{ mouse = "Middle"; action = "PasteSelection";}];
          font = {
            size = 15; # 14 creates glitches on p10k prompt
            normal.family = "MesloLGS NF"; # p10k recommends
          };
        };
      };
      texlive = {
        enable = true;
        extraPackages =  tpkgs: { inherit (tpkgs) scheme-basic wrapfig amsmath ulem hyperref capt-of xcolor dvisvgm dvipng metafont; };
      };

    };
    # sketchybar
    home.file.".config/sketchybar/sketchybarrc".source = ../../.config/sketchybar/sketchybarrc;
    home.file.".config/sketchybar/sketchybarrc".executable = true;

    # Emacs
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-unstable;
    };

    programs.zsh.enable = true;

    # Link apps installed by home-manager.
    home.activation = {
      # macos doesn't support symlink for keyboard layouts
      copyBepoLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                       $DRY_RUN_CMD cp ".dotfiles/macos/Library/Keyboard Layouts/bepo.keylayout" $HOME/Library/Keyboard\ Layouts
      '';
    };
  };
}
