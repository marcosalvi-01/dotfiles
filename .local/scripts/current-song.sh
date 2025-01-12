#!/bin/bash

# Check if playerctl is installed
if ! command -v playerctl &> /dev/null; then
    echo "Error: playerctl is not installed"
    echo "Please install it using your package manager"
    exit 1
fi

# Check playback status
status=$(playerctl status 2>/dev/null)

# Exit silently if nothing is playing
if [ "$status" != "Playing" ]; then
    exit 0
fi

# Get the current player name
player=$(playerctl -l 2>/dev/null | head -n 1)

# Define icons for different players
get_icon() {
    case "$1" in
        "spotify"*)
            echo "󰓇"  # Spotify icon
            ;;
        "firefox"*)
            echo "󰈹"  # Firefox icon
            ;;
        "chromium"*)
            echo "󰊯"  # Chromium icon
            ;;
        "chrome"*)
            echo "󰊯"  # Chrome icon
            ;;
        "vlc"*)
            echo "󰕼"  # VLC icon
            ;;
        *)
            echo ""  # Generic music icon
            ;;
    esac
}

# Get the current song and artist
song=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)

# Output only if there's a song playing
if [ -n "$song" ]; then
    icon=$(get_icon "$player")

    # Format output based on whether artist exists
    if [ -n "$artist" ]; then
        echo "$icon  $song - $artist"
    else
        echo "$icon  $song"
    fi
fi
