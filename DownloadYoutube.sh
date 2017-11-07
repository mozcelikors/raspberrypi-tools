#!/bin/sh

# M.Ozcelikors, mozcelikors@gmail.com 2017

echo "Started YouTube downloader..."
echo "Enter youtube address..."
YTB_ADDRESS=$(zenity --text="Enter youtube address..." --entry)
echo "$YTB_ADDRESS downloaded..."
youtube-dl $YTB_ADDRESS
zenity --info --text="Process complete..."
