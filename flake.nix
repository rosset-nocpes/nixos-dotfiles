{
  description = "Hyprland dotfiles with the BranchOS Quickshell desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Written by scripts/install.sh; ignored by Git, so it is only visible through `path:` flake refs.
      local =
        if builtins.pathExists ./local.nix then import ./local.nix
        else { username = "user"; homeDirectory = "/home/user"; system = "x86_64-linux"; };
      inherit (local) system;

      mkHome = home: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home.nix { inherit home; } ];
      };
    in
    {
      homeModules.default = ./home.nix;
      nixosModules.desktop = ./modules/nixos/desktop.nix;

      homeConfigurations.default = mkHome { inherit (local) username homeDirectory; };

      # The Home Manager CLI matching the locked home-manager input.
      packages.${system}.home-manager = home-manager.packages.${system}.default;

      checks.${system}.home =
        (mkHome { username = "check"; homeDirectory = "/home/check"; }).activationPackage;
    };
}
