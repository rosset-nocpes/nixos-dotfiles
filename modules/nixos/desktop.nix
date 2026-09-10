# Import into an existing NixOS configuration with hardware and users defined.
{ ... }: {
  programs.hyprland.enable = true;
  services.upower.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
}
