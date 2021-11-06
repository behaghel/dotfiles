{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, ...}@inputs:
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
      homeManagerConfigurations = {
        "hub@dell-laptop" = user.mkHMUser {
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
