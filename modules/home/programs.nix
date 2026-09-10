{ pkgs, ... }: {
  home.packages = with pkgs; [
    kdePackages.dolphin brightnessctl playerctl wireplumber
    dejavu_fonts
  ];
  fonts.fontconfig.enable = true;
  programs.kitty = {
    enable = true;
    font = { name = "DejaVu Sans Mono"; size = 11; };
    settings = {
      background = "#18232f";
      foreground = "#e4edf5";
      cursor = "#98bdd9";
      window_padding_width = 12;
      confirm_os_window_close = 0;
    };
  };
  programs.vicinae = { enable = true; systemd.enable = true; };
  xdg.enable = true;
}
