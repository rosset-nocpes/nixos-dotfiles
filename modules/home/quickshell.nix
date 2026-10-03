# The BranchOS shell (config/quickshell) and the tools its controls launch.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    quickshell
    inter # UI font
    hyprsunset # Night light
    hyprlock # Lock
    pavucontrol # Sound settings
    networkmanagerapplet # nm-connection-editor: Wi-Fi details, VPN setup
    blueman # Bluetooth devices
  ];
  fonts.fontconfig.enable = true;
  xdg.configFile."quickshell/branchos".source = ../../config/quickshell;
}
