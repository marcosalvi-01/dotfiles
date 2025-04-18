#!/bin/sh
# Usage: tmux-popup.sh <session> <window-index> <pane-index>
# Isolated “popup” view into an existing pane, with no status/prefix
# and Ctrl-D or Escape to close.
# Creates the session using 'tmux-sessionizer <session>' if it doesn't exist.

# --- Argument Handling ---
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <session> <window-index> <pane-index>" >&2
    exit 1
fi

SESSION="$1"
WINDOW_INDEX="$2"
PANE_INDEX="$3"
SCRATCH="_popup_${SESSION}_${WINDOW_INDEX}_${PANE_INDEX}"

# --- Pre-checks ---
# Check if tmux command exists
command -v tmux >/dev/null 2>&1 \
    || { echo "Error: tmux not found" >&2; exit 127; }

# Check if the target session exists. If not, try to create it.
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Session '$SESSION' not found. Attempting to create it using tmux-sessionizer..." >&2
    # Check if tmux-sessionizer command exists
    if ! command -v tmux-sessionizer >/dev/null 2>&1; then
        echo "Error: 'tmux-sessionizer' command not found. Cannot create session '$SESSION'." >&2
        exit 127 # Standard exit code for command not found
    fi
    # Attempt to create the session using tmux-sessionizer
    if ! tmux-sessionizer -c "$SESSION"; then
        echo "Error: 'tmux-sessionizer \"$SESSION\"' failed to create the session." >&2
        # Double-check if session exists now anyway, maybe tmux-sessionizer succeeded but returned non-zero?
        if ! tmux has-session -t "$SESSION" 2>/dev/null; then
            echo "Error: Session '$SESSION' still does not exist after running tmux-sessionizer." >&2
            exit 1 # Indicate failure to ensure session exists
        else
            echo "Warning: 'tmux-sessionizer \"$SESSION\"' returned an error, but session '$SESSION' now exists. Proceeding..." >&2
        fi
    else
        echo "Session '$SESSION' created successfully via tmux-sessionizer." >&2
		sleep 0.5
    fi
    # Note: If the session was just created, the requested WINDOW_INDEX and PANE_INDEX
    # might not exist. The following checks will handle this scenario.
else
    echo "Session '$SESSION' found." >&2
fi

# Now, proceed with checks for the specific window and pane within the session
# These checks will run against either the pre-existing or newly created session.
tmux list-windows -t "$SESSION" -F '#{window_index}' 2>/dev/null \
    | grep -qx "$WINDOW_INDEX" \
    || { echo "Error: window index '$WINDOW_INDEX' not found in session '$SESSION'." >&2; \
        echo "       (If session was just created, it might only have default windows/panes)." >&2; \
    exit 1; }

tmux list-panes -t "${SESSION}:${WINDOW_INDEX}" -F '#{pane_index}' 2>/dev/null \
    | grep -qx "$PANE_INDEX" \
    || { echo "Error: pane index '$PANE_INDEX' not found in window '$SESSION:$WINDOW_INDEX'." >&2; \
        echo "       (If session was just created, it might only have default windows/panes)." >&2; \
    exit 1; }

# --- Scratch Session Management ---
if ! tmux has-session -t "$SCRATCH" 2>/dev/null; then
    echo "Creating scratch session '$SCRATCH' linked to '$SESSION'..." >&2
    # Create the scratch session linked to the target session
    # The target session ($SESSION) is now guaranteed to exist
    if ! tmux new-session -d -s "$SCRATCH" -t "$SESSION"; then
        echo "Error: Failed to create scratch session '$SCRATCH' linked to '$SESSION'" >&2
        exit 1
    fi
    echo "Scratch session created." >&2

    echo "Configuring scratch session..." >&2
    # Use || true to prevent script exit if a set-option fails (e.g., on older tmux)
    tmux set-option -t "$SCRATCH" status off       >/dev/null 2>&1 || echo "Warning: Couldn't disable status bar for '$SCRATCH'" >&2
    tmux set-option -t "$SCRATCH" prefix None      >/dev/null 2>&1 || echo "Warning: Couldn't disable primary prefix for '$SCRATCH'" >&2
    tmux set-option -t "$SCRATCH" prefix2 None     >/dev/null 2>&1 || echo "Warning: Couldn't disable secondary prefix for '$SCRATCH'" >&2
    tmux set-option -t "$SCRATCH" key-table popup  >/dev/null 2>&1 || echo "Warning: Couldn't set popup key-table for '$SCRATCH'" >&2

    # Build the common close command - ensure quoting handles potential special chars in names
    # Using single quotes inside double quotes for the shell command passed to tmux run-shell
    CLOSE_CMD="tmux detach-client -s '$SCRATCH'; tmux kill-session -t '$SCRATCH'"

    # Bind keys in the popup table. Use || true for robustness.
    tmux bind-key -T popup C-d    run-shell "$CLOSE_CMD" >/dev/null 2>&1 || echo "Warning: Couldn't bind C-d in popup table for '$SCRATCH'" >&2
    tmux bind-key -T popup Escape run-shell "$CLOSE_CMD" >/dev/null 2>&1 || echo "Warning: Couldn't bind Escape in popup table for '$SCRATCH'" >&2

    # Also kill on any client-detach. Use || true for robustness.
    tmux set-hook -t "$SCRATCH" client-detached "$CLOSE_CMD" >/dev/null 2>&1 || echo "Warning: Couldn't set client-detached hook for '$SCRATCH'" >&2

    echo "Configuration complete." >&2
else
    echo "Reusing scratch session '$SCRATCH'." >&2
fi

# --- Execution ---
SCRATCH_TARGET="${SCRATCH}:${WINDOW_INDEX}.${PANE_INDEX}"
echo "Selecting target pane $SCRATCH_TARGET within scratch session..." >&2
# Attempt to select the specific pane within the scratch session
if ! tmux select-pane -t "$SCRATCH_TARGET"; then
    echo "Error: Failed to select pane $SCRATCH_TARGET in scratch session." >&2
    echo "       This might happen if the structure of session '$SESSION' changed" >&2
    echo "       or if the session was just created and lacks this specific pane." >&2
    tmux kill-session -t "$SCRATCH" 2>/dev/null # Clean up scratch session
    exit 1
fi

echo "Attaching client to scratch session, focused on $SCRATCH_TARGET..." >&2
# Attach to the window containing the selected pane in the scratch session
# Using -t "$SCRATCH_TARGET" directly often works and ensures focus.
# If not reliable, could use select-window first, then attach to session.
exec tmux attach-session -t "$SCRATCH_TARGET"

# --- Fallback Error Handling ---
# This part only runs if `exec` fails (e.g., command not found, permissions)
EXIT_CODE=$?
echo "Error: Failed to execute 'tmux attach-session' (code $EXIT_CODE)" >&2
# Attempt cleanup if attach fails
tmux kill-session -t "$SCRATCH" 2>/dev/null
exit $EXIT_CODE
