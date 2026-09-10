{
  description = "Personal Hyprland dotfiles with a Quickshell bar";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      local = if builtins.pathExists ./local.nix then import ./local.nix else {
        username = "user";
        homeDirectory = "/home/user";
        system = "x86_64-linux";
      };
      pkgs = import nixpkgs { inherit (local) system; };
    in {
      homeManagerModules.default = import ./home.nix;
      nixosModules.desktop = import ./modules/nixos/desktop.nix;
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix {
          home = { inherit (local) username homeDirectory; };
        } ];
      };
      checks.${local.system}.home =
        (home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix {
            home.username = "check";
            home.homeDirectory = "/home/check";
          } ];
        }).activationPackage;
    };
}
