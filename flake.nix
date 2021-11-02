{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, ...}@inputs:
    let
      system = "x86_64-linux";
      defaultHubHomeNix = import ./nix/.config/nixpkgs/home.nix;
      pkgs = import nixpkgs {
        inherit system;
        config = import ./nix/.config/nixpkgs/config.nix;
        overlays = [ nur.overlay ];
      };

      inherit (nixpkgs) lib;
      util = import ./._setup/nix/lib {
        inherit system pkgs home-manager lib;
        overlay = (pkgs.overlays);
      };
      inherit (util) user;
      inherit (util) host;
    in {
      homeConfigurations = {
        "hub@dell-laptop" = user.mkHMUser {
          userConfig = {
            git.enable = true;
          };
        };
        # homeManager.lib.homeManagerConfiguration {
        #   configuration = defaultHubHomeNix;
        #   inherit system
        #   homeDirectory = "/home/hub";
        #   username = "hub";
        #   stateVersion = "21.05";
        # };
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
