{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../../bash # FIXME: has to be here for ./zsh to work
    ../../../zsh
    ../../../weechat
  ];

  config = let
    USER = "hub";
    HOME = "/Users/${USER}";
    emailAccountDefault = email: {
        address = email;
        userName = email;
        realName = "Hubert Behaghel";
        folders = {
          inbox = "inbox";
          drafts = "drafts";
          sent = "sent";
          trash = "trash";
        };
        gpg.key = email;

        mu.enable = true;
        msmtp.enable = true;
    };
    gmailAccount = name: email: lang:
      let
        farSent = if lang == "fr" then "[Gmail]/Messages envoy&AOk-s" else "[Gmail]/Sent Mail";
        farTrash = if lang == "fr" then "[Gmail]/Corbeille" else "[Gmail]/Trash";
        farDraft = if lang == "fr" then "[Gmail]/Brouillons" else "[Gmail]/Draft";
        farStarred = if lang == "fr" then "[Gmail]/Important" else "[Gmail]/Starred";
        farAll = if lang == "fr" then "[Gmail]/Tous les messages" else "[Gmail]/All Mail";
        base = emailAccountDefault email;
      in base // {
        flavor = "gmail.com";
        mbsync = {
          enable = true;
          create = "maildir";
          remove = "none";
          expunge = "both";
          groups.${name}.channels = {
            inbox = {
              patterns = [ "INBOX" ];
              extraConfig = {
                CopyArrivalDate = "yes";
                Sync = "All";
              };
            };
            all = {
              farPattern = farAll;
              nearPattern = "archive";
              extraConfig = {
                CopyArrivalDate = "yes";
                Create = "Near";
                Sync = "All";
              };
            };
            starred = {
              farPattern = farStarred;
              nearPattern = "starred";
              extraConfig = {
                CopyArrivalDate = "yes";
                Create = "Near";
                Sync = "All";
              };
            };
            trash = {
              farPattern = farTrash;
              nearPattern = "trash";
              extraConfig = {
                CopyArrivalDate = "yes";
                Create = "Near";
                Sync = "All";
              };
            };
            sent = {
              farPattern = farSent;
              nearPattern = "sent";
              extraConfig = {
                CopyArrivalDate = "yes";
                Create = "Near";
                Sync = "Pull";
              };
            };
          };
        };
      };
  in {
    home.packages = with pkgs;
      let my-aspell = aspellWithDicts (ds: with ds; [en fr es]);
      in [
        neofetch pandoc wget
        mu
        my-aspell
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
    home.file.".config/foo".text = "bar";

    # Email
    accounts.email = {
      maildirBasePath = "${HOME}/Mail";
      accounts = {
        gmail = gmailAccount "gmail" "behaghel@gmail.com" "en" // {
          primary = true;
          passwordCommand = "${pkgs.pass}/bin/pass online/gmail/token";
        };
        "behaghel.fr" = gmailAccount "behaghel.fr" "hubert@behaghel.fr" "fr" // {
          primary = false;
          passwordCommand = "${pkgs.pass}/bin/pass online/behaghel.fr/token";
        };
        "behaghel.org" = emailAccountDefault "hubert@behaghel.org" // {
          primary = false;
          userName = "behaghel@mailfence.com";
          passwordCommand = "${pkgs.pass}/bin/pass online/mailfence.com";
          aliases = ["behaghel@mailfence.com"];
          gpg.signByDefault = true;
          imap = {
            host = "imap.mailfence.com";
            port = 993;
            tls = {
              enable = true;
            };
          };
          smtp = {
            host = "smtp.mailfence.com";
            port = 465;
            tls = {
              enable = true;
            };
          };
          mbsync = {
            enable = true;
            create = "maildir";
            remove = "none";
            expunge = "both";

            groups."behaghel.org".channels = {
              inbox = {
                # patterns = [ "*" "INBOX" "!Spam?" "!Sent Items" "!Archive" "!Trash" "!Drafts" ];
                patterns = [ "INBOX" ];
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Sync = "All";
                };
              };
              archive = {
                farPattern = "Archive";
                nearPattern = "archive";
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Create = "Near";
                  Sync = "All";
                };
              };
              trash = {
                farPattern = "Trash";
                nearPattern = "trash";
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Create = "Near";
                  Sync = "All";
                };
              };
              sent = {
                farPattern = "Sent Items";
                nearPattern = "sent";
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Create = "Near";
                  Sync = "All";
                };
              };
            };
          };
        };
      };
    };
    programs = {
      # at activation it want to init db
      # but mu isn't in the path => home package instead
      mu.enable = false;
      msmtp.enable = true;
      gpg.enable = true;
      mbsync = {
        enable = true;
        extraConfig = ''
SyncState "*"

                 '';
      };
    };

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
        enable = true;
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
      browserpass = {
        enable = true;
        browsers = [ "firefox" ];
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
    home.file.".config/sketchybar/sketchybarrc".source = ../../.config/sketchybar/sketchybarrc;
    home.file.".config/sketchybar/sketchybarrc".executable = true;

    # Emacs
    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
    };

    programs.zsh.enable = true;

    hub.weechat = {
      enable = false;
    };

    # Link apps installed by home-manager.
    home.activation = {
      # FIXME: I had to hardcode the path of mu4e in emacs
      # in the end…
      aliasMu4e = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  $DRY_RUN_CMD mkdir -p $HOME/.local/share $HOME/tmp $HOME/ws;  sudo ln -sfn ${pkgs.mu}/share/emacs $HOME/.local/share
                '';
      # macos doesn't support symlink for keyboard layouts
      copyBepoLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                       $DRY_RUN_CMD cp ".dotfiles/macos/Library/Keyboard Layouts/bepo.keylayout" $HOME/Library/Keyboard\ Layouts
      '';
      # link emacs, vim and password-store: git submodules don't work with home.file (they are empty)
      linkHomeConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  $DRY_RUN_CMD ln -sf .dotfiles/vim/.vim; ln -sf .dotfiles/emacs/.emacs.d; ln -sf .dotfiles/pass/.password-store
      '';
    };
  };
}
