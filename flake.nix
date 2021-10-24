{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs = {
    nur.url = "github:nix-community/NUR";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, homeManager, nur }: {
    let {
      home = import ./nix/.config/nixpkgs/home.nix;
    } in {
      homeConfigurations = {
        "hub@dell-laptop" = homeManager.lib.homeManagerConfiguration {
          configuration = home;
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ nur.overlay ];
          };
          system = "x86_64-linux";
          homeDirectory = "/home/hub";
          username = "hub";
          stateVersion = "21.05";
        };
      };
      home = {
        hub = config;
      }
    }
  };
}
