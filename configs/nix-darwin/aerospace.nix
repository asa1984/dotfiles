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
            alt-h = "focus left";
            alt-l = "focus right";

            alt-shift-h = "move left";
            alt-shift-l = "move right";

            alt-tab = "workspace-back-and-forth";
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

            alt-shift-space = "layout floating tiling";

            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            alt-7 = "workspace 7";
            alt-8 = "workspace 8";
            alt-9 = "workspace 9";
            alt-0 = "workspace 10";

            alt-shift-1 = [
              "move-node-to-workspace 1"
              "workspace 1"
            ];
            alt-shift-2 = [
              "move-node-to-workspace 2"
              "workspace 2"
            ];
            alt-shift-3 = [
              "move-node-to-workspace 3"
              "workspace 3"
            ];
            alt-shift-4 = [
              "move-node-to-workspace 4"
              "workspace 4"
            ];
            alt-shift-5 = [
              "move-node-to-workspace 5"
              "workspace 5"
            ];
            alt-shift-6 = [
              "move-node-to-workspace 6"
              "workspace 6"
            ];
            alt-shift-7 = [
              "move-node-to-workspace 7"
              "workspace 7"
            ];
            alt-shift-8 = [
              "move-node-to-workspace 8"
              "workspace 8"
            ];
            alt-shift-9 = [
              "move-node-to-workspace 9"
              "workspace 9"
            ];
            alt-shift-0 = [
              "move-node-to-workspace 10"
              "workspace 10"
            ];

            alt-r = "mode resize";
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
