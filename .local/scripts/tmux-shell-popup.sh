#!/bin/sh
# Usage: tmux-popup.sh <session> <window-index> <pane-index>
# Isolated “popup” view into an existing pane, with no status/prefix
# and Ctrl-D or Escape to close.

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
command -v tmux >/dev/null 2>&1 \
  || { echo "Error: tmux not found" >&2; exit 127; }

tmux has-session -t "$SESSION" 2>/dev/null \
  || { echo "Error: session '$SESSION' not found" >&2; exit 1; }

tmux list-windows -t "$SESSION" -F '#{window_index}' 2>/dev/null \
  | grep -qx "$WINDOW_INDEX" \
  || { echo "Error: window '$WINDOW_INDEX' not in '$SESSION'" >&2; exit 1; }

tmux list-panes -t "${SESSION}:${WINDOW_INDEX}" -F '#{pane_index}' 2>/dev/null \
  | grep -qx "$PANE_INDEX" \
  || { echo "Error: pane '$PANE_INDEX' not in '$SESSION:$WINDOW_INDEX'" >&2; exit 1; }

# --- Scratch Session Management ---
if ! tmux has-session -t "$SCRATCH" 2>/dev/null; then
  echo "Creating scratch session '$SCRATCH' linked to '$SESSION'..." >&2
  if ! tmux new-session -d -s "$SCRATCH" -t "$SESSION"; then
    echo "Error: Failed to create scratch session '$SCRATCH'" >&2
    exit 1
  fi
  echo "Scratch session created." >&2

  echo "Configuring scratch session..." >&2
  tmux set-option -t "$SCRATCH" status off       >/dev/null 2>&1 \
    || echo "Warning: Couldn't disable status bar" >&2
  tmux set-option -t "$SCRATCH" prefix None      >/dev/null 2>&1 \
    || echo "Warning: Couldn't disable primary prefix" >&2
  tmux set-option -t "$SCRATCH" prefix2 None     >/dev/null 2>&1 \
    || echo "Warning: Couldn't disable secondary prefix" >&2
  tmux set-option -t "$SCRATCH" key-table popup  >/dev/null 2>&1 \
    || echo "Warning: Couldn't set popup key‑table" >&2

  # Build the common close command
  CLOSE_CMD="tmux detach-client -s '$SCRATCH'; tmux kill-session -t '$SCRATCH'"

  # Bind both keys in the popup table (no -n here!) 
  tmux bind-key -T popup C-d    run-shell "$CLOSE_CMD" >/dev/null 2>&1 \
    || echo "Warning: Couldn't bind C-d" >&2
  tmux bind-key -T popup Escape run-shell "$CLOSE_CMD" >/dev/null 2>&1 \
    || echo "Warning: Couldn't bind Escape" >&2

  # Also kill on any client-detach
  tmux set-hook -t "$SCRATCH" client-detached "$CLOSE_CMD" >/dev/null 2>&1 \
    || echo "Warning: Couldn't set client-detached hook" >&2

  echo "Configuration complete." >&2
else
  echo "Reusing scratch session '$SCRATCH'." >&2
fi

# --- Execution ---
SCRATCH_PANE="${SCRATCH}:${WINDOW_INDEX}.${PANE_INDEX}"
echo "Selecting pane $SCRATCH_PANE..." >&2
if ! tmux select-pane -t "$SCRATCH_PANE"; then
  echo "Error: Failed to select pane $SCRATCH_PANE" >&2
  tmux kill-session -t "$SCRATCH" 2>/dev/null
  exit 1
fi

SCRATCH_WINDOW="${SCRATCH}:${WINDOW_INDEX}"
echo "Attaching to window $SCRATCH_WINDOW..." >&2
exec tmux attach-session -t "$SCRATCH_WINDOW"

# If exec failed:
EXIT_CODE=$?
echo "Error: attach failed (code $EXIT_CODE)" >&2
tmux kill-session -t "$SCRATCH" 2>/dev/null
exit $EXIT_CODE
