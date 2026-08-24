{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    slippi = {
      url = "github:lytedev/slippi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, slippi, nixpkgs, ... }@inputs: {
    nixosConfigurations.mother-brain = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        slippi.nixosModules.default {
          environment.systemPackages = [
            slippi.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
