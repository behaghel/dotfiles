{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    mk-darwin-system.url = "github:vic/mk-darwin-system/1321309223d7ef11937bd2539e2da77e5b7e0151";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
    mk-darwin-system.inputs.home-manager.follows = "home-manager";
    mk-darwin-system.inputs.nix-darwin.follows = "nix-darwin";
  };

  outputs = { self, nixpkgs, home-manager, mk-darwin-system, nur, ...}@inputs:
    let
      # TODO: bring this home config and ./macos/._setup/users/hub.nix
      # together: what should be common / specific etc.
      home = import ./nix/.config/nixpkgs/home.nix;
      typeformFlake = mk-darwin-system.mkFlake rec {
        userName = "hub";
        hostName = "tfmbp";
        flake = ./.;
        hostModules = ["${flake}/macos/._setup/hosts/${hostName}.nix"];
        userModules = ["${flake}/macos/._setup/users/${userName}.nix"];
      };
    in typeformFlake;
      #  // {
      # homeConfigurations = {
      #   "hub@dell-laptop" = home-manager.lib.homeManagerConfiguration {
      #     configuration = home;
      #     pkgs = import nixpkgs {
      #       system = "x86_64-linux";
      #       overlays = [ nur.overlay ];
      #     };
      #     system = "x86_64-linux";
      #     homeDirectory = "/home/hub";
      #     username = "hub";
      #     userConfig = {
      #       git.enable = true;
      #       desktop.enable = true;
      #       nix.lorri = true;
      #     };
      #   };
      # };
      # nixosConfigurations =
      # let
      #   system = "x86_64-linux";
      #   pkgs = import nixpkgs {
      #     inherit system;
      #     config = import ./nix/.config/nixpkgs/config.nix;
      #     overlays = [ nur.overlay ];
      #   };

      #   inherit (nixpkgs) lib;
      #   util = import ./._setup/nix/lib {
      #     inherit system pkgs home-manager lib;
      #     overlays = (pkgs.overlays);
      #   };
      #   inherit (util) user;
      #   inherit (util) host;
      # in {
      #   dell-laptop = host.mkHost {
      #     name = "dell-laptop";
      #     kernelPackage = pkgs.linuxPackages;
      #     # taken from hardware.nix
      #     NICs = [];            # take it from hardware.nix
      #     initrdMods = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
      #     kernelMods = [ "kvm-intel" ];
      #     kernelParams = [];
      #     systemConfig = {
      #       # you can shape here the config options that make sense to
      #       # you through modules of your own
      #     };
      #     users = [{
      #       name = "hub";
      #       groups = [ "wheel" "networkmanager" "video" ];
      #       uid = 1000;
      #       shell = pkgs.zsh;
      #     }];
      #     cpuCores = 4;
      #   };
    #   };
    # };
}
