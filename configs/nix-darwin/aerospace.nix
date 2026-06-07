{
  pkgs,
  lib,
  config,
  ...
}:
let
  detectLittleArcSrc = pkgs.writeText "detect-little-arc.m" ''
    #import <Cocoa/Cocoa.h>

    extern AXError _AXUIElementGetWindow(AXUIElementRef element, CGWindowID *windowID);

    int main() {
        NSArray *apps = [NSWorkspace.sharedWorkspace runningApplications];
        for (NSRunningApplication *app in apps) {
            if (![app.bundleIdentifier isEqualToString:@"company.thebrowser.Browser"]) continue;

            AXUIElementRef appRef = AXUIElementCreateApplication(app.processIdentifier);
            CFArrayRef windows = NULL;
            AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&windows);

            if (!windows) { CFRelease(appRef); continue; }

            for (CFIndex i = 0; i < CFArrayGetCount(windows); i++) {
                AXUIElementRef window = (AXUIElementRef)CFArrayGetValueAtIndex(windows, i);
                CFStringRef identifier = NULL;
                AXUIElementCopyAttributeValue(window, kAXIdentifierAttribute, (CFTypeRef *)&identifier);

                if (identifier && CFStringHasPrefix(identifier, CFSTR("littleBrowserWindow"))) {
                    CGWindowID windowID = 0;
                    if (_AXUIElementGetWindow(window, &windowID) == kAXErrorSuccess) {
                        printf("%u\n", windowID);
                    }
                }
                if (identifier) CFRelease(identifier);
            }

            CFRelease(windows);
            CFRelease(appRef);
        }
        return 0;
    }
  '';

  detectLittleArc = pkgs.stdenv.mkDerivation {
    name = "detect-little-arc";
    dontUnpack = true;
    buildPhase = ''
      cc -framework Cocoa -framework ApplicationServices -O2 -o detect-little-arc ${detectLittleArcSrc}
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp detect-little-arc $out/bin/
    '';
  };

  aerospace-float-arc = pkgs.writeShellApplication {
    name = "aerospace-float-arc";
    text = ''
      LOG="/tmp/aerospace-float-arc.log"

      # Wait for the window to be fully registered
      sleep 0.3

      WIDS=$(${detectLittleArc}/bin/detect-little-arc)
      AEROSPACE="${config.services.aerospace.package}/bin/aerospace"

      {
        echo "$(date): callback fired, detected wids=[$WIDS]"
        for wid in $WIDS; do
          "$AEROSPACE" layout floating --window-id "$wid" 2>&1 || true
          echo "$(date): layout floating --window-id $wid exit=$?"
        done
      } >> "$LOG"
    '';
  };

  # Switch to (or move a node to) the Nth workspace assigned to the focused
  # monitor. Works with one monitor too: list-workspaces falls back to all
  # workspaces present on the only monitor.
  aerospace-workspace-relative = pkgs.writeShellApplication {
    name = "aerospace-workspace-relative";
    text = ''
      INDEX="$1"
      MODE="''${2:-focus}"
      AEROSPACE="${config.services.aerospace.package}/bin/aerospace"

      mapfile -t WORKSPACES < <("$AEROSPACE" list-workspaces --monitor focused)
      TARGET="''${WORKSPACES[$((INDEX - 1))]:-}"
      if [ -z "$TARGET" ]; then
        exit 0
      fi

      case "$MODE" in
        focus)
          "$AEROSPACE" workspace "$TARGET"
          ;;
        move)
          "$AEROSPACE" move-node-to-workspace "$TARGET"
          "$AEROSPACE" workspace "$TARGET"
          ;;
      esac
    '';
  };
  wsRel = "${aerospace-workspace-relative}/bin/aerospace-workspace-relative";

  format = pkgs.formats.toml { };
  baseConfigFile = format.generate "aerospace-base.toml" config.services.aerospace.settings;

  # Workaround: nix-darwin cannot serialize on-window-detected correctly (nix-darwin#1271)
  # Append the [[on-window-detected]] section as raw TOML
  aerospaceConfig = pkgs.runCommand "aerospace.toml" { } ''
    sed '/^on-window-detected = \[\]/d' ${baseConfigFile} > $out
    cat >> $out << 'TOML'

    [[on-window-detected]]
    if.app-id = "company.thebrowser.Browser"
    run = "exec-and-forget ${aerospace-float-arc}/bin/aerospace-float-arc"
    TOML
  '';
in
{
  services.aerospace = {
    enable = true;
    settings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 0;
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      gaps = {
        inner = {
          horizontal = 0;
          vertical = 0;
        };
        outer = {
          left = 0;
          bottom = 0;
          top = 0;
          right = 0;
        };
      };

      mode = {
        main = {
          binding = {
            ctrl-alt-h = "focus left";
            ctrl-alt-l = "focus right";

            ctrl-alt-shift-h = "move left";
            ctrl-alt-shift-l = "move right";

            alt-tab = "focus-monitor --wrap-around next";
            alt-shift-tab = "move-node-to-monitor --wrap-around --focus-follows-window next";

            alt-shift-space = "layout floating tiling";

            alt-1 = "exec-and-forget ${wsRel} 1 focus";
            alt-2 = "exec-and-forget ${wsRel} 2 focus";
            alt-3 = "exec-and-forget ${wsRel} 3 focus";
            alt-4 = "exec-and-forget ${wsRel} 4 focus";
            alt-5 = "exec-and-forget ${wsRel} 5 focus";
            alt-6 = "exec-and-forget ${wsRel} 6 focus";
            alt-7 = "exec-and-forget ${wsRel} 7 focus";
            alt-8 = "exec-and-forget ${wsRel} 8 focus";
            alt-9 = "exec-and-forget ${wsRel} 9 focus";
            alt-0 = "exec-and-forget ${wsRel} 10 focus";

            alt-shift-1 = "exec-and-forget ${wsRel} 1 move";
            alt-shift-2 = "exec-and-forget ${wsRel} 2 move";
            alt-shift-3 = "exec-and-forget ${wsRel} 3 move";
            alt-shift-4 = "exec-and-forget ${wsRel} 4 move";
            alt-shift-5 = "exec-and-forget ${wsRel} 5 move";
            alt-shift-6 = "exec-and-forget ${wsRel} 6 move";
            alt-shift-7 = "exec-and-forget ${wsRel} 7 move";
            alt-shift-8 = "exec-and-forget ${wsRel} 8 move";
            alt-shift-9 = "exec-and-forget ${wsRel} 9 move";
            alt-shift-0 = "exec-and-forget ${wsRel} 10 move";

            ctrl-alt-r = "mode resize";
          };
        };

        resize = {
          binding = {
            h = "resize width -50";
            j = "resize height +50";
            k = "resize height -50";
            l = "resize width +50";
            enter = "mode main";
            esc = "mode main";
          };
        };
      };

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "secondary";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "9" = "secondary";
        "10" = "secondary";
      };
    };
  };

  launchd.user.agents.aerospace.command =
    lib.mkForce "${config.services.aerospace.package}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace --config-path ${aerospaceConfig}";
}
