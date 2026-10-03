# Home Manager entry point. Identity (username, home directory) comes from the flake or your own config.
{ lib, ... }: {
  imports = [
    ./modules/home/hyprland.nix
    ./modules/home/programs.nix
    ./modules/home/quickshell.nix
  ];
  home.stateVersion = lib.mkDefault "26.05";
  programs.home-manager.enable = true;
}
