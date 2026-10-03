# System services the desktop relies on. Import into an existing NixOS configuration.
{ ... }: {
  programs.hyprland.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  # Battery, power modes and Bluetooth in the control center.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.bluetooth.enable = true;
}
