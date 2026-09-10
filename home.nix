# Reusable Home Manager entry point; identity belongs in local.nix.
{ lib, ... }: {
  imports = [
    ./modules/home/hyprland.nix
    ./modules/home/programs.nix
    ./modules/home/quickshell.nix
  ];
  home.stateVersion = lib.mkDefault "26.05";
  programs.home-manager.enable = true;
}
