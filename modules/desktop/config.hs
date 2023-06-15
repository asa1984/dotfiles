import Data.Time.Format (defaultTimeLocale, formatTime)

import System.Exit

import XMonad
import qualified XMonad.StackSet as W

import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Layout.MultiToggle
import XMonad.Layout.NoBorders

import XMonad.Hooks.ManageDocks

import Data.Time (getCurrentTime)
import XMonad.Config.Desktop (desktopConfig)
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce (spawnOnce)

main = xmonad myConfig

myConfig =
    def
        { terminal = "wezterm"
        , startupHook = myStartupHook
        , modMask = mod4Mask
        , -- , workspaces = map show [1 .. 9 :: Int]
          borderWidth = 3
        , normalBorderColor = "#222436"
        , focusedBorderColor = "#82aaff"
        , layoutHook = myLayoutHook
        , keys = \c -> mkKeymap c $ myKeys c
        }

-- Startup
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "fcitx5 -D"
    spawnOnce "feh --bg-scale ~/Wallpapers/wallpaper.jpg"
    spawnOnce "discord --start-minimized"
    spawnOnce "slack -u"
    spawnOnce "teams-for-linux --minimized"

-- Keybind
myKeys :: XConfig Layout -> [(String, X ())]
myKeys conf =
    [ ("M-<Return>", spawn $ XMonad.terminal conf)
    , ("M-s", spawn "rofi -show drun -theme launcher")
    , ("M-S-q", kill)
    , ("M1-<Tab>", windows W.focusDown)
    , ("M1-S-<Tab>", windows W.focusUp)
    , ("M-S-f", withFocused $ windows . W.sink)
    , ("M-f", sendMessage NextLayout)
    , ("M-C-<Right>", nextWS)
    , ("M-C-<Left>", prevWS)
    , ("M-S-<Right>", shiftToNext)
    , ("M-S-<Left>", shiftToPrev)
    , ("M-C-d", addWorkspace def)
    , ("M-C-r", removeEmptyWorkspace)
    ]
        -- Workspace
        ++ [ ("M-" ++ m ++ show k, windows $ f i)
           | (i, k) <- zip (XMonad.workspaces conf) ([1 .. 9] :: [Int])
           , (f, m) <- [(W.view, ""), (W.shift, "S-")]
           ]
        -- Media control
        ++ [ ("<XF86AudioPlay>", spawn "playerctl play-pause")
           , ("<XF86AudioNext>", spawn "playerctl next")
           , ("<XF86AudioPrev>", spawn "playerctl previous")
           ]
        -- Screenshot
        ++ [
               ( "<Print>"
               , do
                    spawn "mkdir -p ~/Screenshots"
                    spawn "maim -su | xclip -selection clipboard -t image/png"
                    spawn "dunstify -u low -t 3000 'Screenshot saved to ~/Screenshots'"
               ) -- Copy screenshot to clipboard
           ,
               ( "M-<Print>"
               , do
                    spawn "mkdir -p ~/Screenshots"
                    spawn "maim ~/Screenshots/screenshot-$(date +%Y%m%d%H%M%S).png"
                    spawn "maim -su | xclip -selection clipboard -t image/png"
                    spawn "dunstify -u low -t 3000 'Screenshot saved to ~/Screenshots'"
               ) -- Save screenshot to file
           ,
               ( "M-S-s"
               , spawn "sh ~/Scripts/snipping-tool.sh"
               ) -- Save screenshot to file (select area)
           ]
        -- Utilities
        ++ [ ("<XF86MonBrightnessUp>", spawn "brightnessctl set +10%")
           , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 10%-")
           ]

-- Layout
myLayoutHook =
    avoidStruts $ smartBorders (tall ||| full)
  where
    tall = Tall 1 0.03 0.5
    full = Full
