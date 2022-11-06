{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mk-darwin-system.url = "github:vic/mk-darwin-system/v0.2.0";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, mk-darwin-system, nur, ...}@inputs:
    let
      home = import ./nix/.config/nixpkgs/home.nix;
      darwinFlakeOutput = mk-darwin-system.mkDarwinSystem.m1 {

        # Provide your nix modules to enable configurations on your system.
        #
        modules = [
          # You might want to split them into separate files
          #  ./modules/host-one-module.nix
          #  ./modules/user-one-module.nix
          #  ./modules/user-two-module.nix
          # Or you can inline them here, eg.

          # for configurable nix-darwin modules see
          # https://github.com/LnL7/nix-darwin/blob/master/modules/module-list.nix
          ({ config, pkgs, ... }: {
            environment.systemPackages = with pkgs; [ niv hello ];
          })

          ./macos/._setup/darwin/system.nix


          ({ pkgs, lib, ... }: {
            # Fonts
            fonts = {
              fonts = with pkgs; [
                # fonts that many things (apps, websites) expect
                dejavu_fonts
                liberation_ttf
                roboto
                raleway
                ubuntu_font_family
                # unfree
                # corefonts
                # helvetica-neue-lt-std
                # fonts I use
                etBook
                emacs-all-the-icons-fonts
                # coding fonts
                source-sans-pro
                source-serif-pro
                (nerdfonts.override {
                 enableWindowsFonts = true;
                 fonts = [ "Iosevka" "FiraCode" "Hack" "Inconsolata" "JetBrainsMono" "Hasklig" "Meslo" "Noto" ];
                })
                font-awesome
              ];
              # the modern way in NixOS: fontDir.enable = true;
              enableFontDir = true;
            };


            # skhd
            services.skhd.enable = true;
            services.skhd.skhdConfig = builtins.readFile ./macos/._setup/skhd.conf;

            # System / General
            # Recreate /run/current-system symlink after boot
            services.activate-system.enable = true;
          })


          ./macos/._setup/darwin/yabai.nix
          ./macos/._setup/services/sketchybar
          ./macos/._setup/darwin/sketchybar

          # or configurable home-manager modules see:
          # https://github.com/nix-community/home-manager/blob/master/modules/modules.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }

          # An example of user environment. Change your username.
          (let
            USER = "hub";
            HOME = "/Users/${USER}";
            sent = "sent";
            gmailAccount = name: email:
              let account = email; in {
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
                      farPattern = "[Gmail]/Sent Mail";
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
              #home.homeDirectory = "/Users/hub";
              home.packages = with pkgs;
                let my-aspell = aspellWithDicts (ds: with ds; [en fr es]);
                in [
                  neofetch pandoc wget
                  mu
                  my-aspell
                  # macos only
                  terminal-notifier
                  Anki
                  VLC
                ];
              home.file.".config/foo".text = "bar";
              home.file."Library/Keyboard Layouts/bepo.keylayout".source = ./macos/Library + "/Keyboard\ Layouts/bepo.keylayout";

              # Email
              accounts.email = {
                maildirBasePath = "${HOME}/Mail";
                accounts = {
                  gmail = gmailAccount "gmail" "behaghel@gmail.com" // {
                    primary = true;
                    passwordCommand = "${pkgs.pass}/bin/pass online/gmail/token";
                  };
                  typeform = gmailAccount "typeform" "hubert.behaghel@typeform.com" // {
                    primary = false;
                    passwordCommand = "${pkgs.pass}/bin/pass typeform/login";
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
              home.file.".config/sketchybar/sketchybarrc".text = config.services.sketchybar.extraConfig;
              home.file.".config/sketchybar/sketchybarrc".executable = true;

              # Emacs
              # FIXME: rework all my other git repo that need to be in ~
              # home.file.".emacs.d".source = ./emacs/emacs.d;
              programs.emacs = {
                enable = true;
#                 package =
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
                ./bash # FIXME: has to be here for ./zsh to work
                ./zsh
              ];
              hub.zsh.enable = true;

              # Link apps installed by home-manager.
              home.activation = {
                aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  sudo ln -sfn $genProfilePath/home-path/Applications "$HOME/Applications/HomeManagerApps"
                '';
                aliasMu4e = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  sudo ln -sfn ${pkgs.mu}/share/emacs $genProfilePath/share
                '';
              };
            };
          })

          # for configurable nixos modules see (note that many of them might be linux-only):
          # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/module-list.nix
          ({ lib, ... }: {
            nixpkgs.overlays = import ./macos/._setup/overlay.nix {
              pkgsX86 = nixpkgs.legacyPackages.x86_64-darwin;
              inherit (lib.mds) installNivDmg;
              inherit nur;
            };

            # You can enable supported services (if they work on arm and are not linux only)
            #services.lorri.enable = true;
          })

        ];
      };
    in darwinFlakeOutput // {
      # Your custom flake output here.
      darwinConfigurations."ES-658-GR3BFQ05PM" =
        darwinFlakeOutput.darwinConfiguration.aarch64-darwin;

      homeConfigurations = {
        "hub@dell-laptop" = home-manager.lib.homeManagerConfiguration {
          configuration = home;
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ nur.overlay ];
          };
          system = "x86_64-linux";
          homeDirectory = "/home/hub";
          username = "hub";
          userConfig = {
            git.enable = true;
            desktop.enable = true;
            nix.lorri = true;
          };
        };
      };
      nixosConfigurations =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config = import ./nix/.config/nixpkgs/config.nix;
          overlays = [ nur.overlay ];
        };

        inherit (nixpkgs) lib;
        util = import ./._setup/nix/lib {
          inherit system pkgs home-manager lib;
          overlays = (pkgs.overlays);
        };
        inherit (util) user;
        inherit (util) host;
      in {
        dell-laptop = host.mkHost {
          name = "dell-laptop";
          kernelPackage = pkgs.linuxPackages;
          # taken from hardware.nix
          NICs = [];            # take it from hardware.nix
          initrdMods = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
          kernelMods = [ "kvm-intel" ];
          kernelParams = [];
          systemConfig = {
            # you can shape here the config options that make sense to
            # you through modules of your own
          };
          users = [{
            name = "hub";
            groups = [ "wheel" "networkmanager" "video" ];
            uid = 1000;
            shell = pkgs.zsh;
          }];
          cupCores = 4;
        };
      };
    };
}
