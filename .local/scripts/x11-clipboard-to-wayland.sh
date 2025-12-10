#!/bin/bash
# Monitor X11 clipboard and sync to Wayland

last_clip=""
while true; do
    current_clip=$(xclip -o -selection clipboard 2>/dev/null)
    
    # Only sync if clipboard changed and is not empty
    if [ "$current_clip" != "$last_clip" ] && [ -n "$current_clip" ]; then
        echo "$current_clip" | wl-copy
        last_clip="$current_clip"
    fi
    
    sleep 0.2
done
