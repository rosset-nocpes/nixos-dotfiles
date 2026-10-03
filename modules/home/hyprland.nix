# Hyprland (Lua config) based on the upstream example: same layout, animations,
# gestures and bindings, plus the BranchOS shell.
{ lib, ... }:
let
  lua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };

  terminal = "kitty";
  fileManager = "dolphin";
  menu = "vicinae toggle";
  mainMod = "SUPER";

  exec = command: "hl.dsp.exec_cmd(${toLua command})";
  # `_args` renders as positional arguments: hl.bind(key, action[, flags]).
  bind = key: action: { _args = [ key (lua action) ]; };
  bindWith = flags: key: action: { _args = [ key (lua action) flags ]; };
  media = bindWith { locked = true; repeating = true; };

  workspaceBinds = lib.concatMap (workspace:
    let key = toString (lib.mod workspace 10);
    in [
      (bind "${mainMod} + ${key}" "hl.dsp.focus({ workspace = ${toString workspace} })")
      (bind "${mainMod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString workspace} })")
    ]) (lib.range 1 10);

  bezier = name: p1: p2: { _args = [ name { type = "bezier"; points = [ p1 p2 ]; } ]; };
  animation = leaf: speed: curve: extra:
    { inherit leaf speed; enabled = true; } // curve // extra;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland itself comes from the system (see modules/nixos/desktop.nix).
    package = null;
    portalPackage = null;
    systemd.enable = false;
    configType = "lua";

    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("quickshell -c branchos")
      end)
    '';

    settings = {
      monitor = { output = ""; mode = "preferred"; position = "auto"; scale = "auto"; };

      env = [
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
      ];

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          col = {
            active_border = { colors = [ "rgba(33ccffee)" "rgba(00ff99ee)" ]; angle = 45; };
            inactive_border = "rgba(595959aa)";
          };
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 5;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
          # Frosted bar and popups; windows are opaque, so this mostly affects the shell.
          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            vibrancy = 0.1696;
          };
        };

        animations.enabled = true;
        dwindle.preserve_split = true;
        master.new_status = "master";
        scrolling.fullscreen_on_one_column = true;

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad.natural_scroll = false;
        };
      };

      curve = [
        (bezier "easeOutQuint" [ 0.23 1 ] [ 0.32 1 ])
        (bezier "easeInOutCubic" [ 0.65 0.05 ] [ 0.36 1 ])
        (bezier "linear" [ 0 0 ] [ 1 1 ])
        (bezier "almostLinear" [ 0.5 0.5 ] [ 0.75 1 ])
        (bezier "quick" [ 0.15 0 ] [ 0.1 1 ])
        { _args = [ "easy" { type = "spring"; mass = 1; stiffness = 238.1191; dampening = 24.21279333; } ]; }
      ];

      animation =
        let
          b = name: { bezier = name; };
          spring = name: { spring = name; };
          fade = { style = "fade"; };
          popin = { style = "popin 87%"; };
        in
        [
          (animation "global" 10 (b "default") { })
          (animation "border" 5.39 (b "easeOutQuint") { })
          (animation "windows" 4.79 (spring "easy") { })
          (animation "windowsIn" 4.1 (spring "easy") popin)
          (animation "windowsOut" 1.49 (b "linear") popin)
          (animation "fadeIn" 1.73 (b "almostLinear") { })
          (animation "fadeOut" 1.46 (b "almostLinear") { })
          (animation "fade" 3.03 (b "quick") { })
          (animation "layers" 3.81 (b "easeOutQuint") { })
          (animation "layersIn" 4 (b "easeOutQuint") fade)
          (animation "layersOut" 1.5 (b "linear") fade)
          (animation "fadeLayersIn" 1.79 (b "almostLinear") { })
          (animation "fadeLayersOut" 1.39 (b "almostLinear") { })
          (animation "workspaces" 1.94 (b "almostLinear") fade)
          (animation "workspacesIn" 1.21 (b "almostLinear") fade)
          (animation "workspacesOut" 1.94 (b "almostLinear") fade)
          (animation "zoomFactor" 7 (b "quick") { })
        ];

      gesture = { fingers = 3; direction = "horizontal"; action = "workspace"; };

      bind = [
        (bind "${mainMod} + Q" (exec terminal))
        (bind "${mainMod} + C" "hl.dsp.window.close()")
        (bind "${mainMod} + M" (exec "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
        (bind "${mainMod} + E" (exec fileManager))
        (bind "${mainMod} + V" ''hl.dsp.window.float({ action = "toggle" })'')
        (bind "${mainMod} + R" (exec menu))
        (bind "${mainMod} + P" "hl.dsp.window.pseudo()")
        (bind "${mainMod} + J" ''hl.dsp.layout("togglesplit")'')
      ]
      ++ map (direction: bind "${mainMod} + ${direction}" ''hl.dsp.focus({ direction = "${direction}" })'')
        [ "left" "right" "up" "down" ]
      ++ workspaceBinds
      ++ [
        (bind "${mainMod} + S" ''hl.dsp.workspace.toggle_special("magic")'')
        (bind "${mainMod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')
        (bind "${mainMod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (bind "${mainMod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')
        (bindWith { mouse = true; } "${mainMod} + mouse:272" "hl.dsp.window.drag()")
        (bindWith { mouse = true; } "${mainMod} + mouse:273" "hl.dsp.window.resize()")

        (media "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
        (media "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
        (media "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
        (media "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
        (media "XF86MonBrightnessUp" (exec "brightnessctl -e4 -n2 set 5%+"))
        (media "XF86MonBrightnessDown" (exec "brightnessctl -e4 -n2 set 5%-"))
      ]
      ++ map ({ key, command }: bindWith { locked = true; } key (exec command)) [
        { key = "XF86AudioNext"; command = "playerctl next"; }
        { key = "XF86AudioPause"; command = "playerctl play-pause"; }
        { key = "XF86AudioPlay"; command = "playerctl play-pause"; }
        { key = "XF86AudioPrev"; command = "playerctl previous"; }
      ];

      layer_rule = [
        {
          name = "blur-branchos-bar";
          match.namespace = "^branchos-bar$";
          blur = true;
          blur_popups = true;
          # Skip the fully transparent bar area and faint shadows.
          ignore_alpha = 0.3;
        }
      ];

      window_rule = [
        {
          name = "suppress-maximize-events";
          match.class = ".*";
          suppress_event = "maximize";
        }
        {
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
        {
          name = "move-hyprland-run";
          match.class = "hyprland-run";
          move = "20 monitor_h-120";
          float = true;
        }
      ];
    };
  };
}
