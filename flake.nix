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
    mk-darwin-system.url = "github:vic/mk-darwin-system/v0.2.0";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, mk-darwin-system, nur, ...}@inputs:
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
                  # "com.apple.trackpad.scaling"         = "3.0";
                  AppleFontSmoothing = 1;
                  ApplePressAndHoldEnabled = true;
                  AppleKeyboardUIMode = 3;
                  AppleMeasurementUnits                = "Centimeters";
                  AppleMetricUnits                     = 1;
                  AppleShowScrollBars                  = "Automatic";
                  AppleShowAllExtensions = true;
                  AppleTemperatureUnit                 = "Celsius";
                  # InitialKeyRepeat                     = 15;
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
                SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
              };
            };
          }

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
              programs.git = {
                enable = true;
                userName = "Hubert Behaghel";
                userEmail = "behaghel@gmail.com";
              };
              home.file.".vim".source = ./vim/.vim;
              programs.password-store = {
                enable = true;
		settings = { 
                  PASSWORD_STORE_DIR = "$HOME/.password-store";
                };
              };
              programs.zsh.enable = true;
              programs.firefox = {
                enable = true;
                package = pkgs.Firefox;
                extensions = with pkgs.nur.repos.rycee.firefox-addons; [
                  ublock-origin
                  browserpass
                  org-capture
                  vimium
                ];
                profiles = 
                let
                  settings = {
                    "app.update.auto" = false;
                  };
                in {
                  home = {
                    id = 0;
                    inherit settings;
                  };
                  work = {
                    id = 1;
                    inherit settings;
                  };
                  ext-typeform = {
                    id = 2;
                    inherit settings;
                  };
                };
              };
              programs.browserpass = {
                enable = true;
                browsers = [ "firefox" ];
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
      nixosConfigurations = {
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
