import System.Exit

import Control.Monad (when)

import XMonad
import qualified XMonad.StackSet as W

import XMonad.Util.EZConfig (mkKeymap)
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.Types (Direction1D (Next, Prev))

import XMonad.Actions.CycleWS (
    WSType (WSIs),
    moveTo,
    nextWS,
    prevWS,
    shiftTo,
    shiftToNext,
    shiftToPrev,
 )
import XMonad.Actions.PhysicalScreens (viewScreen)

import XMonad.Hooks.ManageDocks (avoidStruts)

import XMonad.Layout.IndependentScreens (
    countScreens,
    onCurrentScreen,
    unmarshallS,
    withScreens,
    workspaces',
 )
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Spacing (smartSpacingWithEdge)
import XMonad.Layout.ToggleLayouts (ToggleLayout (ToggleLayout), toggleLayouts)

main :: IO ()
main = do
    n <- countScreens
    xmonad $
        def
            { terminal = "wezterm"
            , modMask = mod4Mask
            , borderWidth = 2
            , normalBorderColor = "#222436"
            , focusedBorderColor = "#82aaff"
            , startupHook = myStartupHook
            , workspaces = withScreens n (map show [1 .. 9 :: Int])
            , keys = \c -> mkKeymap c $ myKeys c
            , layoutHook = myLayoutHook
            }

-- Startup
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "feh --bg-scale ~/.hm_desktop/wallpaper.jpg"
    spawnOnce "fcitx5 -D"
    spawnOnce "discord --start-minimized"
    spawnOnce "slack -u"
    spawnOnce "teams-for-linux --minimized"

-- Keybind
myKeys :: XConfig Layout -> [(String, X ())]
myKeys conf =
    [ ("M-<Return>", spawn $ XMonad.terminal conf)
    , ("M-S-q", kill)
    , ("M1-<Tab>", windows W.focusDown)
    , ("M1-S-<Tab>", windows W.focusUp)
    , ("M-S-f", withFocused $ windows . W.sink)
    , ("M-f", sendMessage ToggleLayout)
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
        ++ [ ("M-s", spawn "rofi -show drun -theme launcher")
           , ("M-l", spawn "betterlockscreen -l")
           , ("M-S-c", spawn "xcolor | xargs -I {} sh -c 'echo \"{}\" | xclip -selection clipboard && dunstify -t 3000 \"Copied\" \"{}\"'")
           , ("<XF86AudioPlay>", spawn "playerctl play-pause")
           , ("<XF86AudioNext>", spawn "playerctl next")
           , ("<XF86AudioPrev>", spawn "playerctl previous")
           , ("<XF86MonBrightnessUp>", spawn "brightnessctl set +10%")
           , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 10%-")
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
    avoidStruts $
        toggleLayouts (noBorders Full) $
            smartSpacingWithEdge gap $
                smartBorders tall
  where
    tall = Tall 1 0.03 0.5
    gap = 6
