#!/bin/bash

# Function to open URL based on OS
open_url() {
    local url="$1"
    case "$(uname -s)" in
        Darwin*)  open "$url" ;;          # macOS
        *)        xdg-open "$url" ;;      # Linux and others
    esac
}

# Save terminal settings to restore later
old_stty=$(stty -g)

# Print instructions
echo -n "  "

# Initialize query
query=""

# Use a different approach - temporarily create a keystroke collector
# (This avoids the issues with read and terminal settings)
exec < /dev/tty
# Set terminal to raw mode but keeping signals
stty raw -echo isig

while true; do
    # Read a single byte
    char=$(dd bs=1 count=1 2>/dev/null)
    
    # Get ASCII value of the character
    ascii=$(printf "%d" "'$char")
    
    # ESC key (ASCII 27)
    if [ "$ascii" -eq 27 ]; then
        echo -e "\nExiting."
        break
    fi
    
    # Enter key (ASCII 13 - Carriage Return)
    if [ "$ascii" -eq 13 ]; then
        echo  # Print newline
        
        # If query is not empty, process it
        if [ -n "$query" ]; then
            # Restore terminal settings
            stty "$old_stty"
            
            # URL encode the query
            encoded=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$query")
            url="https://www.google.com/search?q=${encoded}"
            
            # Open the URL in the default browser
            open_url "$url"
            exit 0
        else
            echo "No search query provided. Exiting."
            break
        fi
    fi
    
    # Backspace or Delete (ASCII 127 or 8)
    if [ "$ascii" -eq 127 ] || [ "$ascii" -eq 8 ]; then
        if [ -n "$query" ]; then
            query="${query%?}"  # Remove last character
            echo -ne "\b \b"    # Move back, erase, move back
        fi
    # Normal character - add to query and display
    elif [ "$ascii" -ge 32 ] && [ "$ascii" -le 126 ]; then
        query="$query$char"
        echo -n "$char"
    fi
done

# Always restore terminal settings
stty "$old_stty"
exit 0
