let
  USER = "hub";
  HOME = "/Users/${USER}";
  gmailAccount = name: email: lang:
    let
      account = email;
      sent = "sent";
      farSent = if lang == "fr" then "[Gmail]/Messages envoy&AOk-s" else "[Gmail]/Sent Mail";
    in {
      flavor = "gmail.com";
      address = account;
      userName = account;
      realName = "Hubert Behaghel";
      folders = {
        inbox = "inbox";
        drafts = "drafts";
        inherit sent;
        #trash = "trash";
      };
      gpg.key = account;

      mu.enable = true;
      msmtp.enable = true;
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
            };
          };
          # FIXME: I couldn't find a way to guarantee to
          # have all my GMail emails in my client
          # (Gmail/All Mail does that) without creating
          # duplicates and particularly unread duplicates
          # the "fix" is to never archive emails elsewhere
          # but on the client (e.g. no send + archive on
          # the web client)
          #                     all = {
          #                       farPattern = "[Gmail]/All Mail";
          #                       nearPattern = "archive";
          #                       extraConfig = {
          #                         CopyArrivalDate = "yes";
          #                         Create = "Near";
          #                       };
          #                     };
          #                     starred = {
          #                       farPattern = "[Gmail]/Starred";
          #                       nearPattern = "starred";
          #                       extraConfig = {
          #                         CopyArrivalDate = "yes";
          #                         Create = "Near";
          #                       };
          #                     };
          #                     trash = {
          #                       farPattern = "[Gmail]/Trash";
          #                       nearPattern = "trash";
          #                       extraConfig = {
          #                         CopyArrivalDate = "yes";
          #                         Create = "Near";
          #                         Sync = "Pull";
          #                       };
          #                     };
          sent = {
            farPattern = farSent;
            nearPattern = sent;
            extraConfig = {
              CopyArrivalDate = "yes";
              Create = "Near";
              Sync = "Pull";
            };
          };
        };
      };
    };
in { pkgs, lib, config, ... }: {
  users.users.${USER}.home = HOME;
  home-manager.users.${USER} = {
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
        nivApps.Anki
        nivApps.VLC
        nivApps.Zotero
        nivApps.Kindle
      ];
    home.file.".config/foo".text = "bar";
    home.file."Library/Keyboard Layouts/bepo.keylayout".source = ../../Library + "/Keyboard\ Layouts/bepo.keylayout";

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
      };
    };
    programs = {
      # at activation it want to init db
      # but mu isn't in the path => home package instead
      mu.enable = false;
      msmtp.enable = true;
      mbsync = {
        enable = true;
        extraConfig = ''
SyncState "*"

                 '';
      };
    };

    programs = {
      git = {
        enable = true;
        userName = "Hubert Behaghel";
        userEmail = "behaghel@gmail.com";
      };
      # FIXME: it's empty in the store home.file.".vim".source = ./vim/.vim;
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
        };
      };
      firefox = {
        enable = true;
        package = pkgs.Firefox;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          browserpass
          org-capture
          vimium
        ];
        profiles =
          let settings = {
                "app.update.auto" = true;
                # no top tabs => tabcenter on the side
                "browser.tabs.inTitlebar" = 0;
                # reopen windows and tabs on startup
                "browser.startup.page" = 3;
              };
          in {
            home = {
              id = 0;
              inherit settings;
            };
            work2 = {
              id = 1;
              settings = settings // {
                "extensions.activeThemeID" = "cheers-bold-colorway@mozilla.org";
              };
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
          macos_option_as_alt = "yes";
          scrollback_lines = 10000;
        };
        font = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
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
    # FIXME: rework all my other git repo that need to be in ~
    # home.file.".emacs.d".source = ./emacs/emacs.d;
    programs.emacs = {
      enable = true;
      package = pkgs.emacsUnstable;
      #                   let
      #                     # TODO: derive 'name' from assignment
      #                     elPackage = name: src:
      #                       pkgs.runCommand "${name}.el" { } ''
      #             mkdir -p  $out/share/emacs/site-lisp
      #             cp -r ${src}/* $out/share/emacs/site-lisp/
      #           '';
      #                   in
      #                     (
      #                       pkgs.emacsWithPackagesFromUsePackage {
      #                         alwaysEnsure = true;
      #                         # alwaysTangle = true;
      # 
      #                         # Custom overlay derived from 'emacs' flake input
      #                         package = pkgs.emacs;
      #                         config = builtins.readFile "${pkgs.hubert-emacs.d}/init.el";
      # 
      #                         override = epkgs: epkgs // {
      #                           mu4e-dashboard = elPackage "mu4e-dashboard" (
      #                             pkgs.fetchFromGitHub {
      #                               owner = "rougier";
      #                               repo = "mu4e-dashboard";
      #                               rev = "40b2d48da55b7ac841d62737ea9cdf54e8442cf3";
      #                               sha256 = "1i94gdyk9f5c2vyr184znr54cbvg6apcq38l2389m3h8lxg1m5na";
      #                             }
      #                           );
      #                         };
      # 
      #                         extraEmacsPackages = epkgs: with epkgs; [
      #                           mu4e-dashboard
      #                         ];
      #                       }
      #                     );
    };

    imports = [
      ../../../bash # FIXME: has to be here for ./zsh to work
      ../../../zsh
    ];
    hub.zsh.enable = true;

    # Link apps installed by home-manager.
    home.activation = {
      aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  sudo ln -sfn $genProfilePath/home-path/Applications "$HOME/Applications/HomeManagerApps"
                '';
      # FIXME: I had to hardcode the path of mu4e in emacs
      # in the end…
      aliasMu4e = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  sudo ln -sfn ${pkgs.mu}/share/emacs $genProfilePath/share
                '';
    };
  };
}
