import XMonad

main :: IO ()
main = xmonad myConfig

myConfig =
    def
        { terminal = "alacritty"
        , modMask = mod4Mask
        , borderWidth = 4
        , normalBorderColor = "#000000"
        , focusedBorderColor = "#0000ff"
        }
