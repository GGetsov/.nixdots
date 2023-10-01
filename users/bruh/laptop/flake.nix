{
  description = "Home manager laptop config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, ... }@inputs:
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    overlays = [
      inputs.neovim-nightly-overlay.overlay
    ];

  in {
    homeConfigurations = {
      bruh = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ({nixpkgs.overlays = overlays;})
          ../src/home.nix
          ];
      }; 
    };
  };
}
