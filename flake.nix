{
  description = "hub's home";

  inputs.nur.url = "github:nix-community/NUR";

  outputs = { self, nixpkgs, nur}: {
    nixosModules = {
      # User configuration for desktop
      home = {
        imports = [
          ./nix/.config/nixpkgs/home.nix
          { nixpkgs.overlays = [ nur.overlay ]; }
        ];
      };
    };
  };
}
