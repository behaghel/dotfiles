{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/21.11";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spacebar.url = "github:cmacrae/spacebar/v1.3.0";
    mk-darwin-system.url = "github:vic/mk-darwin-system/v0.2.0";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, mk-darwin-system, nur, spacebar, ...}@inputs:
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

          { # nix-darwin system config
            system = {
              keyboard = {
                enableKeyMapping = true;
                remapCapsLockToEscape = true;
                userKeyMapping = [
                  { # right alt -> right control
                    HIDKeyboardModifierMappingSrc = 30064771302;
                    HIDKeyboardModifierMappingDst = 30064771300;
                  }
                  { # right cmd -> right alt
                    HIDKeyboardModifierMappingSrc = 30064771303;
                    HIDKeyboardModifierMappingDst = 30064771302;
                  }
                ];
              };
              defaults = {
                finder = {
                  AppleShowAllExtensions = true;
                  FXEnableExtensionChangeWarning = false;
                  CreateDesktop = false; # disable desktop icons
                };
                NSGlobalDomain = {
                  # "com.apple.trackpad.scaling"       = "3.0";
                  AppleFontSmoothing                   = 1;
                  # don't ruin vim motions in Terminal
                  ApplePressAndHoldEnabled             = false;
                  AppleKeyboardUIMode                  = 3;
                  AppleMeasurementUnits                = "Centimeters";
                  AppleMetricUnits                     = 1;
                  AppleShowScrollBars                  = "Automatic";
                  AppleShowAllExtensions               = true;
                  AppleTemperatureUnit                 = "Celsius";
                  # InitialKeyRepeat                   = 15;
                  KeyRepeat                            = 2;
                  NSAutomaticCapitalizationEnabled     = false;
                  NSAutomaticSpellingCorrectionEnabled = false;
                  NSAutomaticPeriodSubstitutionEnabled = false;
                  _HIHideMenuBar                       = true;
                  NSNavPanelExpandedStateForSaveMode = true;
                  NSNavPanelExpandedStateForSaveMode2 = true;
                  # Enable full keyboard access for all controls
                  # (e.g. enable Tab in modal dialogs)
                };
                dock = {
                  autohide = true;
                  mru-spaces = false;
                  minimize-to-application = true;
                };
                SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
              };
            };
          }

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
                 fonts = [ "Iosevka" "FiraCode" "Inconsolata" "JetBrainsMono" "Hasklig" "Meslo" "Noto" ];
                })
              ];
              # the modern way in NixOS: fontDir.enable = true;
              enableFontDir = true;
            };

            # Yabai
            services.yabai = {
              enable = true;
              package = pkgs.yabai;
              enableScriptingAddition = true;
              config = {
                focus_follows_mouse = "autoraise";
                mouse_follows_focus = "off";
                mouse_drop_action = "stack";
                window_placement = "second_child";
                window_opacity = "off";
                window_topmost = "on";
                window_shadow = "float";
                window_border = "on";
                window_border_width = 5;
                active_window_border_color = "0xff81a1c1";
                normal_window_border_color = "0xff3b4252";
                active_window_opacity = "1.0";
                normal_window_opacity = "1.0";
                split_ratio = "0.50";
                auto_balance = "on";
                mouse_modifier = "fn";
                mouse_action1 = "move";
                mouse_action2 = "resize";
                layout = "bsp";
                top_padding = 10;
                bottom_padding = 10;
                left_padding = 10;
                right_padding = 10;
                window_gap = 10;
                external_bar = "main:26:0";
              };
              extraConfig = pkgs.lib.mkDefault ''
                # rules
                yabai -m rule --add app='System Preferences' manage=off
                yabai -m rule --add app='Emacs' title='.*Minibuf.*' manage=off border=off
                '';
            };
            launchd.user.agents.yabai.serviceConfig.StandardErrorPath = "/tmp/yabai.log";
            launchd.user.agents.yabai.serviceConfig.StandardOutPath = "/tmp/yabai.log";

            # Spacebar
            services.spacebar.enable = true;
            services.spacebar.package = pkgs.spacebar;
            services.spacebar.config = {
              debug_output = "on";
              display = "main";
              position = "top";
              clock_format = "%R";
              text_font = ''"Roboto Mono:Regular:12.0"'';
              icon_font = ''"Font Awesome 5 Free:Solid:12.0"'';
              background_color = "0xff222222";
              foreground_color = "0xffd8dee9";
              space_icon_color = "0xffffab91";
              dnd_icon_color = "0xffd8dee9";
              clock_icon_color = "0xffd8dee9";
              power_icon_color = "0xffd8dee9";
              battery_icon_color = "0xffd8dee9";
              power_icon_strip = " ";
              space_icon = "•";
              space_icon_strip = "1 2 3 4 5 6 7 8 9 10";
              spaces_for_all_displays = "on";
              display_separator = "on";
              display_separator_icon = "";
              space_icon_color_secondary = "0xff78c4d4";
              space_icon_color_tertiary = "0xfffff9b0";
              clock_icon = "";
              dnd_icon = "";
              right_shell = "on";
              right_shell_icon = "";
              right_shell_icon_color = "0xffd8dee9";
            };

            #launchd.user.agents.spacebar.serviceConfig.EnvironmentVariables.PATH = pkgs.lib.mkForce
            #  (builtins.replaceStrings [ "$HOME" ] [ config.users.users.hub.home ] config.environment.systemPath);
            launchd.user.agents.spacebar.serviceConfig.StandardErrorPath = "/tmp/spacebar.err.log";
            launchd.user.agents.spacebar.serviceConfig.StandardOutPath = "/tmp/spacebar.out.log";

            # skhd
            services.skhd.enable = true;
            services.skhd.skhdConfig = builtins.readFile ./macos/._setup/skhd.conf;

            # System / General
            # Recreate /run/current-system symlink after boot
            services.activate-system.enable = true;
          })

          # or configurable home-manager modules see:
          # https://github.com/nix-community/home-manager/blob/master/modules/modules.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }

          # An example of user environment. Change your username.
          ({ pkgs, lib, ... }: {
            home-manager.users."hub" = {
              home.packages = with pkgs; [ neofetch pandoc wget ];
              home.file.".config/foo".text = "bar";
              home.file."Library/Keyboard Layouts/bepo.keylayout".source = ./macos/Library + "/Keyboard\ Layouts/bepo.keylayout";
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
                zsh.enable = true;
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
                      "app.update.auto" = false;
                    };
                    in {
                      home = {
                        id = 0;
                        inherit settings;
                      };
                      work = {
                        id = 1;
                        settings = settings // {
                          "extensions.activeThemeID" = "cheers-bold-colorway@mozilla.org";
                        };
                      };
                      ext-typeform = {
                        id = 2;
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
                  enable = true;
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
              };

              # Link apps installed by home-manager.
              home.activation = {
                aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  sudo ln -sfn $genProfilePath/home-path/Applications "$HOME/Applications/HomeManagerApps"
                '';
              };
            };
          })

          # for configurable nixos modules see (note that many of them might be linux-only):
          # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/module-list.nix
          ({ lib, ... }: {
            # You can provide an overlay for packages not available or that fail to compile on arm.
             nixpkgs.overlays = let nivSources = import ./macos/._setup/nix/sources.nix;
               in [
                 nur.overlay
                 spacebar.overlay
                 (new: old: {
                   inherit (nixpkgs.legacyPackages.x86_64-darwin) pandoc niv;

                   Firefox = lib.mds.installNivDmg {
                     name = "Firefox";
                     src = nivSources.Firefox;
                   };
                 })
               ];

            # You can enable supported services (if they work on arm and are not linux only)
            #services.lorri.enable = true;
          })

        ];
      };
    in darwinFlakeOutput // {
      # Your custom flake output here.
      darwinConfigurations."TF-GR3BFQ05PM" =
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
