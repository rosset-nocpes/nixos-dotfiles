{ lib, ... }:
let
  lua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };

  terminal = "kitty";
  fileManager = "dolphin";
  menu = "vicinae toggle";
  mainMod = "SUPER";

  exec = command: "hl.dsp.exec_cmd(${toLua command})";

  mkBind = key: action: {
    _args = [
      key
      (lua action)
    ];
  };

  mkBindWithFlags = key: action: flags: {
    _args = [
      key
      (lua action)
      flags
    ];
  };

  mkWorkspaceBinds = workspace: key: [
    (mkBind "${mainMod} + ${key}" "hl.dsp.focus({ workspace = ${toString workspace} })")
    (mkBind "${mainMod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString workspace} })")
  ];

  workspaceBinds =
    lib.concatMap
      (workspace: mkWorkspaceBinds workspace (toString workspace))
      (lib.range 1 9)
    ++ mkWorkspaceBinds 10 "0";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = null;
    portalPackage = null;
    configType = "lua";

    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("quickshell -c nixos-setup")
      end)
    '';

    settings = {
      # ------------------
      # MONITORS
      # ------------------

      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "auto";
      };

      # ------------------
      # ENVIRONMENT
      # ------------------

      env = [
        {
          _args = [
            "XCURSOR_SIZE"
            "24"
          ];
        }
        {
          _args = [
            "HYPRCURSOR_SIZE"
            "24"
          ];
        }
      ];

      # ------------------
      # CONFIGURATION
      # ------------------

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;

          col = {
            active_border = {
              colors = [
                "rgba(33ccffee)"
                "rgba(00ff99ee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(595959aa)";
          };

          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        animations.enabled = true;

        dwindle.preserve_split = true;
        master.new_status = "master";
        scrolling.fullscreen_on_one_column = true;

        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = false;
        };

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          follow_mouse = 1;
          sensitivity = 0;

          touchpad.natural_scroll = false;
        };
      };

      # ------------------
      # ANIMATIONS
      # ------------------

      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [
                  0.23
                  1
                ]
                [
                  0.32
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0.05
                ]
                [
                  0.36
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [
                  0
                  0
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  0.5
                ]
                [
                  0.75
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [
                  0.15
                  0
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easy"
            {
              type = "spring";
              mass = 1;
              stiffness = 238.1191;
              dampening = 24.21279333;
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          spring = "easy";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          spring = "easy";
          style = "popin 87%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "zoomFactor";
          enabled = true;
          speed = 7;
          bezier = "quick";
        }
      ];

      # ------------------
      # INPUT
      # ------------------

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # ------------------
      # KEYBINDINGS
      # ------------------

      bind =
        [
          (mkBind "${mainMod} + Q" (exec terminal))
          (mkBind "${mainMod} + C" "hl.dsp.window.close()")
          (mkBind "${mainMod} + M" (exec "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
          (mkBind "${mainMod} + E" (exec fileManager))
          (mkBind "${mainMod} + V" ''hl.dsp.window.float({ action = "toggle" })'')
          (mkBind "${mainMod} + R" (exec menu))
          (mkBind "${mainMod} + P" "hl.dsp.window.pseudo()")
          (mkBind "${mainMod} + J" ''hl.dsp.layout("togglesplit")'')

          # Focus
          (mkBind "${mainMod} + left" ''hl.dsp.focus({ direction = "left" })'')
          (mkBind "${mainMod} + right" ''hl.dsp.focus({ direction = "right" })'')
          (mkBind "${mainMod} + up" ''hl.dsp.focus({ direction = "up" })'')
          (mkBind "${mainMod} + down" ''hl.dsp.focus({ direction = "down" })'')
        ]
        ++ workspaceBinds
        ++ [
          # Special workspace
          (mkBind "${mainMod} + S" ''hl.dsp.workspace.toggle_special("magic")'')
          (mkBind "${mainMod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')

          # Existing workspaces
          (mkBind "${mainMod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (mkBind "${mainMod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

          # Mouse move/resize
          (mkBindWithFlags "${mainMod} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
          (mkBindWithFlags "${mainMod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

          # Locked/repeating media keys
          (mkBindWithFlags "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+") {
            locked = true;
            repeating = true;
          })
          (mkBindWithFlags "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
            locked = true;
            repeating = true;
          })
          (mkBindWithFlags "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") {
            locked = true;
            repeating = true;
          })
          (mkBindWithFlags "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") {
            locked = true;
            repeating = true;
          })
          (mkBindWithFlags "XF86MonBrightnessUp" (exec "brightnessctl -e4 -n2 set 5%+") {
            locked = true;
            repeating = true;
          })
          (mkBindWithFlags "XF86MonBrightnessDown" (exec "brightnessctl -e4 -n2 set 5%-") {
            locked = true;
            repeating = true;
          })

          # Player controls
          (mkBindWithFlags "XF86AudioNext" (exec "playerctl next") { locked = true; })
          (mkBindWithFlags "XF86AudioPause" (exec "playerctl play-pause") { locked = true; })
          (mkBindWithFlags "XF86AudioPlay" (exec "playerctl play-pause") { locked = true; })
          (mkBindWithFlags "XF86AudioPrev" (exec "playerctl previous") { locked = true; })
        ];

      # ------------------
      # WINDOW RULES
      # ------------------

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
