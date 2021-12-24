{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spacebar.url = "github:cmacrae/spacebar/v1.3.0";
    yabai-src = {
      url = "github:koekeishiya/yabai/master";
      flake = false;
    };
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
                userKeyMapping = let
                  pow =
                    let
                      pow' = base: exponent: value:
                        # FIXME: It will silently overflow on values > 2**62 :(
                        # The value will become negative or zero in this case
                        if exponent == 0
                        then 1
                        else if exponent <= 1
                        then value
                        else (pow' base (exponent - 1) (value * base));
                    in base: exponent: pow' base exponent base;
                  hexToDec = v:
                    let
                      hexToInt = {
                        "0" = 0; "1" = 1;  "2" = 2;
                        "3" = 3; "4" = 4;  "5" = 5;
                        "6" = 6; "7" = 7;  "8" = 8;
                        "9" = 9; "A" = 10; "B" = 11;
                        "C" = 12;"D" = 13; "E" = 14;
                        "F" = 15;
                      };
                      chars = nixpkgs.lib.stringToCharacters v;
                      charsLen = builtins.length chars;
                    in
                      nixpkgs.lib.lists.foldl
                        (a: v: a + v)
                        0
                        (nixpkgs.lib.lists.imap0
                          (k: v: hexToInt."${v}" * (pow 16 (charsLen - k - 1)))
                          chars);
                  translateKey = (value:
                  # hidutil accepts values that consists of 0x700000000 binary ORed with the
                  # desired keyboard usage value.
                  #
                  # The actual number can be base-10 or hexadecimal.
                  # 0x700000000
                  #
                  # 30064771072 == 0x700000000
                  #
                  # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
                    builtins.bitOr 30064771072 (hexToDec value));
                  in [
                    # GLOBAL MAPPINGS
                    # magic keyboard Vendor ID:	0x004C Product ID:	0x029C
                    # builtin keyboard Vendor ID:	0x05ac (Apple Inc.) Product ID:	0x0341
                    { # right alt -> right control
                      # 0xE6 => 30064771302
                      HIDKeyboardModifierMappingSrc = translateKey "E6";
                      HIDKeyboardModifierMappingDst = translateKey "E4";
                    }
                    { # right cmd -> right alt
                      HIDKeyboardModifierMappingSrc = translateKey "E7";
                      HIDKeyboardModifierMappingDst = translateKey "E6";
                    }
                    # DEVICE SPECIFIC MAPPINGS
                    # TODO: create a module with
                    # a deviceSpecificMappings options
                    # try to combine global mappings and device
                    # specific one getting inspiration from
                    # https://github.com/LnL7/nix-darwin/pull/210/files#diff-419506783ec861ca10717edb955cc3b39db637bbc691fc1ddac1f4dfaf522adeR224
                    # hopefully it could be enough to force
                    # system.activationScript.keyboard.text
                    # with several line one per product ID
                    # https://github.com/LnL7/nix-darwin/blob/master/modules/system/keyboard.nix#L71
                    # it looks like mixing global and device-specific
                    # remapping is a bad idea so one hidutil command
                    # per product ID should be all
                    # Realforce
                    # Product ID:	0x0124
                    # Vendor ID:	0x0853
                    # left cmd <=> left alt
                    # {
                    #   HIDKeyboardModifierMappingSrc = translateKey "E3";
                    #   HIDKeyboardModifierMappingDst = translateKey "E2";
                    # }
                    # {
                    #   HIDKeyboardModifierMappingSrc = translateKey "E2";
                    #   HIDKeyboardModifierMappingDst = translateKey "E3";
                    # }
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
                font-awesome
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
                window_placement = "second_child";
                window_opacity = "on";
                window_topmost = "on";
                window_shadow = "on";
                window_border = "on";
                # window_border_width = 5;
                # active_window_border_color = "0xff81a1c1";
                # normal_window_border_color = "0xff3b4252";
                active_window_opacity = "1.0";
                normal_window_opacity = "0.9";
                split_ratio = "0.50";
                auto_balance = "on";
                mouse_modifier = "fn";
                mouse_action1 = "move";
                mouse_action2 = "resize";
                focus_follows_mouse = "autoraise";
                mouse_follows_focus = "off";
                mouse_drop_action = "stack";
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
                yabai -m rule --add app='About This Mac' manage=off
                yabai -m rule --add app='System Information' manage=off
                yabai -m rule --add app='System Preferences' manage=off
                yabai -m rule --add app='zoom.us' manage=off
                yabai -m rule --add app=emacs-27.2 manage=on
                yabai -m rule --add label=emacs app=Emacs manage=on
                '';
                # zoom.us simply crashes if its windows are managed by yabai...
                # yabai -m rule --add app='Emacs' title='.*Minibuf.*' manage=off border=off
            };
            launchd.user.agents.yabai.serviceConfig.StandardErrorPath = "/tmp/yabai.err.log";
            launchd.user.agents.yabai.serviceConfig.StandardOutPath = "/tmp/yabai.log";

            # Spacebar
            services.spacebar.enable = true;
            services.spacebar.package = pkgs.spacebar;
            services.spacebar.config = {
              # general
              debug_output = "on";
              display = "all";
              position = "top";
              background_color = "0xff222222";
              foreground_color = "0xffd8dee9";
              text_font = ''"Roboto Mono:Regular:12.0"'';
              icon_font = ''"Font Awesome 5 Free:Solid:12.0"'';
              # spaces (left)
              space_icon = "•";
              space_icon_color = "0xffffab91";
              space_icon_color_secondary = "0xff78c4d4";
              space_icon_color_tertiary = "0xfffff9b0";
              space_icon_strip = "1 2 3 4 5 6 7 8 9 10";
              spaces_for_all_displays = "on";
              display_separator = "on";
              display_separator_icon = "";
              # info (right)
              clock_format = "%R";
              clock_icon = "";
              clock_icon_color = "0xffd8dee9";
              dnd_icon = "";
              dnd_icon_color = "0xffd8dee9";
              power_icon_strip = " ";
              power_icon_color = "0xffd8dee9";
              battery_icon_color = "0xffd8dee9";
              right_shell = "on";
              right_shell_icon = "";
              right_shell_icon_color = "0xffd8dee9";
              # TODO: print # unread emails
              right_shell_command = "whoami";
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
          ({ pkgs, lib, config, ... }: {
            home-manager.users.hub = {
              #home.homeDirectory = "/Users/hub";
              home.packages = with pkgs; [
                neofetch pandoc wget
                # macos only
                terminal-notifier
              ];
              home.file.".config/foo".text = "bar";
              home.file."Library/Keyboard Layouts/bepo.keylayout".source = ./macos/Library + "/Keyboard\ Layouts/bepo.keylayout";
              # Emacs
              home.file.".emacs.d".source = ./emacs/emacs.d;
              programs.emacs = {
                enable = true;
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
                  enable = false; # see https://github.com/NixOS/nixpkgs/pull/137512
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
                    font = {
                      size = 15; # 14 creates glitches on p10k prompt
                      normal.family = "MesloLGS NF"; # p10k recommends
                    };
                  };
                };
              };

              # Emacs
              # FIXME: rework all my other git repo that need to be in ~
              # home.file.".emacs.d".source = ./emacs/emacs.d;
              programs.emacs = {
                enable = true;
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
                 (final: prev: {
                  yabai = let
                    version = "4.0.0-dev";
                    buildSymlinks = prev.runCommand "build-symlinks" { } ''
                      mkdir -p $out/bin
                      ln -s /usr/bin/xcrun /usr/bin/xcodebuild /usr/bin/tiffutil /usr/bin/qlmanage $out/bin
                    '';
                  in prev.yabai.overrideAttrs (old: {
                    inherit version;
                    src = inputs.yabai-src;
                    buildInputs = with prev.darwin.apple_sdk.frameworks; [
                      Carbon
                      Cocoa
                      ScriptingBridge
                      prev.xxd
                      SkyLight
                    ];
                    nativeBuildInputs = [ buildSymlinks ];
                  });
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
