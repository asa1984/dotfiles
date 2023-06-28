filePath=~/Screenshots/screenshot_$(date +%Y-%m-%dT%H:%M:%S).png
mkdir -p ~/Screenshots
maim --hidecursor $filePath
xclip -selection clipboard -t image/png < $filePath
dunstify -u low -t 3000 'Screenshot saved to ~/Screenshots'
