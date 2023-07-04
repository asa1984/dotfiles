import System.Exit

import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.PhysicalScreens
import qualified XMonad.StackSet as W

import XMonad.Hooks.ManageDocks

import XMonad.Layout.IndependentScreens
import XMonad.Layout.MultiToggle
import XMonad.Layout.NoBorders

import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce (spawnOnce)

main = do
    n <- countScreens
    xmonad $
        myConfig
            { workspaces = withScreens n (map show [1 .. 9 :: Int])
            }

myConfig =
    def
        { terminal = "wezterm"
        , startupHook = myStartupHook
        , modMask = mod4Mask
        , borderWidth = 3
        , normalBorderColor = "#222436"
        , focusedBorderColor = "#82aaff"
        , layoutHook = myLayoutHook
        , keys = \c -> mkKeymap c $ myKeys c
        }

-- Startup
myStartupHook :: X ()
myStartupHook = do
    -- if multiple screens, set wallpaper to the first screenBy
    n <- countScreens
    if n > 1
        then spawnOnce "sh ~/.hm_desktop/polybar.sh"
        else spawnOnce "sh ~/.hm_desktop/polybar.sh --single"
    spawnOnce "feh --bg-scale ~/.hm_desktop/wallpaper.jpg"
    spawnOnce "fcitx5 -D"
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
    , ("M-S-<Right>", shiftTo Next spacesOnCurrentScreen)
    , ("M-S-<Left>", shiftTo Prev spacesOnCurrentScreen)
    , ("M-<Left>", viewScreen def 0)
    , ("M-<Right>", viewScreen def 1)
    ]
        -- Workspace - create virtual workspaces for each screen
        ++ [ ("M-" ++ m ++ show k, windows $ onCurrentScreen f i)
           | (i, k) <- zip (workspaces' conf) ([1 .. 9] :: [Int])
           , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]
           ]
        -- Workspace - move to next or previous virtual workspace
        ++ [ ("M-C-<Right>", moveTo Next spacesOnCurrentScreen)
           , ("M-C-<Left>", moveTo Prev spacesOnCurrentScreen)
           ]
        -- Screenshot
        ++ [
               ( "<Print>"
               , do
                    spawn "maim --hidecursor | xclip -selection clipboard -t image/png"
                    spawn "dunstify -u low -t 3000 'Screenshot copied to clipboard'"
               ) -- Copy screenshot to clipboard
           ,
               ( "M-<Print>"
               , spawn "sh ~/.hm_desktop/screenshot.sh"
               ) -- Save screenshot to file
           ,
               ( "M-S-s"
               , spawn "sh ~/.hm_desktop/snipping_tool.sh"
               ) -- Save screenshot to file (select area)
           ]
        -- Utilities
        ++ [ ("<XF86AudioPlay>", spawn "playerctl play-pause")
           , ("<XF86AudioNext>", spawn "playerctl next")
           , ("<XF86AudioPrev>", spawn "playerctl previous")
           , ("<XF86MonBrightnessUp>", spawn "brightnessctl set +10%")
           , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 10%-")
           , ("M-S-c", spawn "xcolor | xargs -I {} sh -c 'echo \"{}\" | xclip -selection clipboard && dunstify -t 3000 \"Copied\" \"{}\"'")
           ]

-- Workspace - get workspaces on current screen
isOnScreen :: ScreenId -> WindowSpace -> Bool
isOnScreen s ws = s == unmarshallS (W.tag ws)

currentScreen :: X ScreenId
currentScreen = gets (W.screen . W.current . windowset)

spacesOnCurrentScreen :: WSType
spacesOnCurrentScreen = WSIs $ do
    s <- currentScreen
    return $ \x -> W.tag x /= "NSP" && isOnScreen s x

-- Layout
myLayoutHook =
    avoidStruts $ smartBorders (tall ||| full)
  where
    tall = Tall 1 0.03 0.5
    full = Full
