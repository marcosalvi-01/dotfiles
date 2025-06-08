#!/bin/bash

# Gruvbox color palette
FG='\033[38;2;212;190;152m'     # fg: #d4be98 (base foreground)
GRAY='\033[38;2;168;153;132m'   # accent.gray: #a89984
BLUE='\033[38;2;125;174;163m'   # accent.blue: #7daea3
GREEN='\033[38;2;142;192;124m'  # accent.green: #8ec07c
YELLOW='\033[38;2;216;166;87m'  # accent.yellow: #d8a657
PURPLE='\033[38;2;211;134;155m' # accent.purple: #d3869b
RED='\033[38;2;234;105;98m'     # accent.red: #ea6962
RESET='\033[0m'

# Function to display the git status
display_status() {
    local pull_indicator="$1"
    local push_indicator="$2"

    # Build the colorized output
    branch_info="${BLUE}󰘬 $(git branch --show-current)${RESET}"

    git_stats=$(git status --porcelain | awk '
    BEGIN{m=0;a=0;d=0;r=0;u=0}
    /^.M|^M./{m++}
    /^A.|^.A/{a++}
    /^.D|^D./{d++}
    /^R./{r++}
    /^\?\?/{u++}
    END{printf " %d  %d  %d  %d  %d", m,a,d,r,u}')

    # Parse the stats and colorize each part
    IFS=' ' read -r modified added deleted renamed untracked <<< "$git_stats"
    colorized_stats="${YELLOW} ${modified}${RESET} ${GREEN} ${added}${RESET} ${RED} ${deleted}${RESET} ${PURPLE} ${renamed}${RESET} ${GRAY}? ${untracked}${RESET}"

    commit_msg="${BLUE} '$(git log --oneline -1 --pretty=format:'%s')'${RESET}"

    # Combine all parts (including pull/push indicators if present)
    indicators="${pull_indicator}${push_indicator}"
    if [ -n "$indicators" ]; then
        output="${branch_info}${indicators} ${FG}|${RESET} ${colorized_stats} ${FG}|${RESET} ${commit_msg}"
    else
        output="${branch_info} ${FG}|${RESET} ${colorized_stats} ${FG}|${RESET} ${commit_msg}"
    fi

    # Calculate terminal width and center the output
    # Strip ANSI codes to get actual character length for proper centering
    clean_output=$(echo -e "$output" | sed 's/\x1b\[[0-9;]*m//g')
    output_length=${#clean_output}
    terminal_width=$(tput cols)

    # Calculate how many lines the output will occupy
    lines_needed=$(((output_length + terminal_width - 1) / terminal_width))

    # Clear all lines that might contain previous output
    for ((i=1; i<lines_needed; i++)); do
        printf "\033[A\033[K"  # Move up one line and clear it
    done
    printf "\r\033[K"  # Clear current line

    # Center the output
    if [ $output_length -lt $terminal_width ]; then
        padding=$(((terminal_width - output_length) / 2))
        printf "%*s%s" "$padding" "" "$(echo -e "$output")"
    else
        # Output is too long, print it and then handle truncation
        printf "%s" "$(echo -e "$output")"
    fi
}

# Check if we have an upstream branch
current_branch=$(git branch --show-current)
upstream_branch=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)

# Display initial status immediately (without remote info)
display_status "" ""

# If we have an upstream, start background fetch and update when done
if [ -n "$upstream_branch" ]; then
    # Create a temporary file to signal when fetch is complete
    temp_file=$(mktemp)

    # Start fetch in background
    (
        git fetch --quiet 2>/dev/null || true
        echo "done" > "$temp_file"
    ) &

    fetch_pid=$!

    # Wait for fetch to complete (with a reasonable timeout)
    timeout=10  # 10 second timeout
    elapsed=0

    while [ $elapsed -lt $timeout ]; do
        if [ -f "$temp_file" ] && [ "$(cat "$temp_file" 2>/dev/null)" = "done" ]; then
            # Fetch completed, calculate remote status
            pull_indicator=""
            push_indicator=""

            # Count commits behind (to pull)
            commits_behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")

            if [ "$commits_behind" -gt 0 ]; then
                pull_indicator=" ${GRAY}⇣ ${commits_behind}${RESET}"
            fi

            # Count commits ahead (to push)
            commits_ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")

            if [ "$commits_ahead" -gt 0 ]; then
                push_indicator=" ${PURPLE}⇡ ${commits_ahead}${RESET}"
            fi

            # Update the display with remote info
            display_status "$pull_indicator" "$push_indicator"
            break
        fi

        sleep 0.1
        elapsed=$((elapsed + 1))
    done

    # Clean up
    rm -f "$temp_file"

    # If fetch is still running after timeout, kill it
    if kill -0 $fetch_pid 2>/dev/null; then
        kill $fetch_pid 2>/dev/null
    fi
fi

# Add final newline
echo
