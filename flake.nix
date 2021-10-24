{
  description = "hub's home";

  # Nix User Repository: user-contributed packages
  inputs.nur.url = "github:nix-community/NUR";

  outputs = { self, nixpkgs, nur }: {
    nixosModules = {
      dotfiles = {
        imports = [
          ./nix/.config/nixpkgs/home.nix
          { nixpkgs.overlays = [ nur.overlay ]; }
        ];
      };
    };
  };
}
