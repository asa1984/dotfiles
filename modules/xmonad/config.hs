import XMonad

main :: IO()
main=xmonad myConfig

myConfig= def
    { terminal = "alacritty"
    , modMask = mod1Mask
    , borderWidth = 2
    , normalBorderColor = "#000000"
    , focusedBorderColor = "#0000ff"
    }
