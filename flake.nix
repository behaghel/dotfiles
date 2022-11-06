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
      # TODO: bring this home config and ./macos/._setup/users/hub.nix
      # together: what should be common / specific etc.
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

            # System / General
            # Recreate /run/current-system symlink after boot
            services.activate-system.enable = true;
          })


          ./macos/._setup/darwin/yabai.nix
          ./macos/._setup/services/sketchybar
          ./macos/._setup/darwin/sketchybar
          ./macos/._setup/darwin/skhd

          # or configurable home-manager modules see:
          # https://github.com/nix-community/home-manager/blob/master/modules/modules.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }

          ./macos/._setup/users/hub.nix

          # for configurable nixos modules see (note that many of them might be linux-only):
          # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/module-list.nix
          ({ lib, ... }: {
            nixpkgs.overlays = import ./macos/._setup/overlay.nix {
              pkgsX86 = nixpkgs.legacyPackages.x86_64-darwin;
              inherit (lib.mds) installNivDmg;
              inherit nur;
            };
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
