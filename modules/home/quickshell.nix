{ pkgs, ... }: {
  home.packages = [ pkgs.quickshell ];
  xdg.configFile."quickshell/nixos-setup".source = ../../config/quickshell;
}
