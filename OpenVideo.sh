#!/bin/sh

# Author: M.Ozcelikors, mozcelikors@gmail.com, 2017

echo "Started video playing process..."
echo "Select the video file..."
VIDEOFILE=$(zenity --title="Select the video file..." --file-selection)
echo "File is being opened... $VIDEOFILE"

#TODO: How to exit omxplayer after mouse is used
lxterminal -e omxplayer "$VIDEOFILE" -o local #hdmi,local,alsa,both
