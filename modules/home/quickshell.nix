{ pkgs, ... }: {
  home.packages = [
    pkgs.quickshell
    pkgs.grim
    (pkgs.python3.withPackages (ps: [ ps.pillow ]))
  ];
  xdg.configFile."quickshell/nixos-setup".source = ../../config/quickshell;
}
