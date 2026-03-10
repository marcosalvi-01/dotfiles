#!/usr/bin/env python3

from __future__ import annotations

import curses
from dataclasses import dataclass
import logging
import os
import pathlib
import shlex
import subprocess
import sys
from typing import List, Tuple, Set

# ────────────────────────────── debug / logging ─────────────────────────── #

DEBUG_ENABLED = (
    os.getenv("TMUX_SPINE_DEBUG") in {"1", "true", "yes"} or "--debug" in sys.argv
)

if "--debug" in sys.argv:
    sys.argv.remove("--debug")

cache_dir = (
    pathlib.Path(os.getenv("XDG_CACHE_HOME", os.path.expanduser("~/.cache"))) / "tmux"
)
cache_dir.mkdir(parents=True, exist_ok=True)
LOG_FILE = cache_dir / "spine.log"

logging.basicConfig(
    filename=str(LOG_FILE),
    filemode="a",
    level=logging.DEBUG if DEBUG_ENABLED else logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

log = logging.getLogger("spine")
log.debug("\n————— New run ————— (%s)", " ".join(sys.argv))

# ────────────────────────────── configuration ───────────────────────────── #

INDEX_CHARS = list(os.getenv("TMUX_SPINE_CHARS", "neiatsrchd0123456789"))

CONFIG_BASE = pathlib.Path(
    os.getenv("XDG_CONFIG_HOME", os.path.expanduser("~/.config")), "tmux", "spine"
)

STORE_FILE = pathlib.Path(
    os.getenv(
        "TMUX_SPINE_FILE",
        os.path.join(CONFIG_BASE, "sessions"),
    )
)

# File to store the all-sessions order
ALL_SESSIONS_ORDER_FILE = pathlib.Path(os.path.join(CONFIG_BASE, "all_sessions_order"))

# Base popup options without dimensions
POPUP_BASE_OPTS = os.getenv(
    "TMUX_SPINE_POPUP_BASE_OPTS",
    '-E -b rounded -T "#[align=centre fg=blue bold] Tmux Spine "',
)

# Min/max dimensions for the popup
MIN_WIDTH = 20
MIN_HEIGHT = 3
MAX_WIDTH_PCT = 50
MAX_HEIGHT_PCT = 60

# Padding and buffer space for popup
WIDTH_PADDING = 4
HEIGHT_PADDING = 2

# ───────────────────────────── tmux helpers ─────────────────────────────── #


def tmx(cmd: str) -> str:
    """Run *tmux cmd* and return stdout (empty string on error)."""
    log.debug("tmux %s", cmd)

    try:

        command_parts = ["tmux"] + shlex.split(cmd)
        cp = subprocess.run(
            command_parts,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )
        if cp.stderr and DEBUG_ENABLED:
            log.debug("tmux-stderr: %s", cp.stderr.strip())
        if cp.returncode != 0 and DEBUG_ENABLED:
            log.debug("tmux command failed with code %d", cp.returncode)
        return cp.stdout.rstrip("\n")
    except Exception as e:
        log.error("Error running tmux command '%s': %s", cmd, e)
        return ""


def current_session() -> str:
    """Return the name of the current tmux session."""
    name = tmx("display -p '#S'")
    log.debug("current session name: %s", name)
    return name


def all_live_session_names() -> Set[str]:
    """Return a set of names of all currently running tmux sessions."""
    names = set(tmx("list-sessions -F '#S'").splitlines())
    names = {name for name in names if not (name.startswith("_"))}
    log.debug("live session names: %s", names)
    return names


def get_terminal_size() -> Tuple[int, int]:
    """Get terminal dimensions from tmux."""
    width_str = tmx("display -p '#{client_width}'")
    height_str = tmx("display -p '#{client_height}'")
    try:
        width = int(width_str)
        height = int(height_str)
        log.debug("terminal size: %dx%d", width, height)
        return width, height
    except ValueError:
        log.error(
            "Could not parse terminal dimensions: width='%s', height='%s'",
            width_str,
            height_str,
        )

        return 80, 24


def jump_to_session(name: str) -> None:
    """Switch to session *name* using external sessionizer, else tmux fallback."""
    log.info("jump → %s", name)
    try:
        res = subprocess.run(
            ["tmux-sessionizer", name], capture_output=True, text=True, check=False
        )
        if res.returncode != 0:
            log.debug(
                "sessionizer failed (%s) or not found – falling back to tmux switch-client",
                res.returncode,
            )

            tmx(f"switch-client -t {shlex.quote(name)}")

    except FileNotFoundError:
        log.debug("tmux-sessionizer not found – falling back to tmux switch-client")
        tmx(f"switch-client -t {shlex.quote(name)}")
    except Exception as e:
        log.error("Error during jump_to_session for '%s': %s", name, e)

        tmx(f"switch-client -t {shlex.quote(name)}")


def kill_session(name: str) -> None:
    """Kill the tmux session with the given *name*."""
    log.info("kill session %s", name)

    tmx(f"kill-session -t {shlex.quote(name)}")


def show_status(msg: str) -> None:
    """Display a message in the tmux status line."""
    tmx(f"display-message -d 1000 {shlex.quote(msg)}")


# ───────────────────────────── data storage ─────────────────────────────── #


def load_store() -> List[str]:
    """Load the list of bookmarked session names from the store file."""
    if not STORE_FILE.exists():
        log.debug("store file missing – returning empty list")
        return []
    try:
        names = STORE_FILE.read_text().splitlines()
        names = [n for n in names if n.strip()]
        log.debug("loaded store (names): %s", names)
        return names
    except Exception as e:
        log.error("Failed to load store file '%s': %s", STORE_FILE, e)
        return []


def save_store(names: List[str]) -> None:
    """Save the list of session names to the store file."""
    try:
        STORE_FILE.parent.mkdir(parents=True, exist_ok=True)
        names_to_save = names[: len(INDEX_CHARS)]
        with STORE_FILE.open("w") as fh:
            for name in names_to_save:
                fh.write(f"{name}\n")
        log.debug("saved store (%d names)", len(names_to_save))
    except Exception as e:
        log.error("Failed to save store file '%s': %s", STORE_FILE, e)


def load_all_sessions_order() -> List[str]:
    """Load the custom order for all sessions."""
    if not ALL_SESSIONS_ORDER_FILE.exists():
        log.debug("all-sessions order file missing – returning empty list")
        return []
    try:
        names = ALL_SESSIONS_ORDER_FILE.read_text().splitlines()
        names = [n for n in names if n.strip()]
        log.debug("loaded all-sessions order (names): %s", names)
        return names
    except Exception as e:
        log.error(
            "Failed to load all-sessions order file '%s': %s",
            ALL_SESSIONS_ORDER_FILE,
            e,
        )
        return []


def save_all_sessions_order(names: List[str]) -> None:
    """Save the custom order for all sessions."""
    try:
        ALL_SESSIONS_ORDER_FILE.parent.mkdir(parents=True, exist_ok=True)
        names_to_save = names[: len(INDEX_CHARS)]
        with ALL_SESSIONS_ORDER_FILE.open("w") as fh:
            for name in names_to_save:
                fh.write(f"{name}\n")
        log.debug("saved all-sessions order (%d names)", len(names_to_save))
    except Exception as e:
        log.error(
            "Failed to save all-sessions order file '%s': %s",
            ALL_SESSIONS_ORDER_FILE,
            e,
        )


def load_order(use_all_sessions: bool) -> List[str]:
    """Load persisted order for the selected mode."""
    if use_all_sessions:
        return load_all_sessions_order()
    return load_store()


def save_order(use_all_sessions: bool, names: List[str]) -> None:
    """Save persisted order for the selected mode."""
    if use_all_sessions:
        save_all_sessions_order(names)
    else:
        save_store(names)


def build_session_names(use_all_sessions: bool, live_names: Set[str] | None = None) -> List[str]:
    """Build the list of sessions to display for the selected mode."""
    if not use_all_sessions:
        return load_order(False)

    if live_names is None:
        live_names = all_live_session_names()

    custom_order = load_order(True)
    ordered_names = [name for name in custom_order if name in live_names]

    # Keep custom order stable; append newly discovered live sessions at the end.
    ordered_set = set(custom_order)
    new_live_names = [name for name in tmx("list-sessions -F '#S'").splitlines() if name and not name.startswith("_") and name not in ordered_set]

    if new_live_names:
        save_order(True, custom_order + new_live_names)

    return ordered_names + new_live_names


def no_sessions_message(use_all_sessions: bool) -> str:
    """Return the empty-list message for the selected mode."""
    if use_all_sessions:
        return "No active sessions. Press Esc/q."
    return "No bookmarked sessions. Press Esc/q."


# ────────────────────────── session formatting ──────────────────────────── #


@dataclass
class SessionState:
    """In-memory state for popup interaction."""

    use_all_sessions: bool
    names: List[str]
    live_names: Set[str]
    current_name: str
    cursor: int = 0


def format_session_line(
    idx: int, name: str, is_live: bool, current_name: str | None = None
) -> str:
    """Format session line for display with index character and live/dead status."""
    mark = INDEX_CHARS[idx]
    dead_marker = "   dead" if not is_live else ""
    current_marker = "   active" if current_name and name == current_name else ""
    return f"{mark} {name}{dead_marker}{current_marker}"


# ───────────────────────────── add command ──────────────────────────────── #


def cmd_add() -> None:
    """Add the current session name to the top of the bookmarks."""
    current_name = current_session()
    if not current_name:
        log.error("Could not get current session name.")
        show_status("Error: Could not get current session name.")
        return

    names = load_order(False)
    names = [n for n in names if n != current_name]
    names.append(current_name)
    save_order(False, names)
    show_status(f"[Tmux Spine] Session added to the list.")


# ───────────────────────────── list command ─────────────────────────────── #


def cmd_list() -> None:
    """List bookmarked sessions, indicating liveness and assigned index char."""
    names = load_order(False)
    if not names:
        print("No bookmarked sessions.")
        return

    live_names = all_live_session_names()
    for idx, name in enumerate(names):
        if idx >= len(INDEX_CHARS):
            print(f"? {name} (no index char available)")
            continue
        print(format_session_line(idx, name, name in live_names))


# ───────────────────────────── popup command ────────────────────────────── #


def calculate_popup_dimensions(use_all_sessions: bool = False) -> Tuple[int, int]:
    """Calculate appropriate dimensions for the popup based on content."""
    live_names = all_live_session_names()
    names_list = build_session_names(use_all_sessions, live_names)
    extra_text = no_sessions_message(use_all_sessions)
    current_name = current_session()

    if not names_list:
        content_width = len(extra_text)
        content_height = 1
    else:
        max_line_len = 0
        limited_names = names_list[: len(INDEX_CHARS)]
        for idx, name in enumerate(limited_names):
            line = format_session_line(idx, name, name in live_names, current_name)
            max_line_len = max(max_line_len, len(line))
        content_width = max_line_len
        content_height = len(limited_names)

    width = content_width + WIDTH_PADDING
    height = content_height + HEIGHT_PADDING

    width = max(width, MIN_WIDTH)
    height = max(height, MIN_HEIGHT)

    term_width, term_height = get_terminal_size()
    max_width = term_width * MAX_WIDTH_PCT // 100
    max_height = term_height * MAX_HEIGHT_PCT // 100

    max_width = max(max_width, MIN_WIDTH)
    max_height = max(max_height, MIN_HEIGHT)

    width = min(width, max_width)
    height = min(height, max_height)

    log.debug("calculated popup dimensions: %dx%d", width, height)
    return width, height


def launch_popup(use_all_sessions: bool = False) -> None:
    """Launch popup with dynamically calculated dimensions."""
    width, height = calculate_popup_dimensions(use_all_sessions)
    popup_opts = f"{POPUP_BASE_OPTS} -w {width} -h {height}"

    script_path_arg = shlex.quote(sys.argv[0])
    debug_arg = " --debug" if DEBUG_ENABLED else ""
    all_sessions_arg = " --all" if use_all_sessions else ""
    popup_cmd = f"display-popup {popup_opts} {script_path_arg} __inpopup{debug_arg}{all_sessions_arg}"

    tmx(popup_cmd)


KEY_ENTER = {curses.KEY_ENTER, 10, 13}
KEY_CTRL_D = 4
KEY_ESC = 27
KEY_UP = {curses.KEY_UP, ord("k")}
KEY_DOWN = {curses.KEY_DOWN, ord("j")}
KEY_RIGHT = curses.KEY_RIGHT
KEY_LEFT = curses.KEY_LEFT
DEFAULT_INPUT_TIMEOUT_MS = 25
ESC_DELAY_MS = 125
# Try to get correct Shift+Up/Down codes if available
try:
    KEY_SHIFT_UP = curses.KEY_SR
    KEY_SHIFT_DOWN = curses.KEY_SF
except:
    log.warning("curses.KEY_SR/SF not available, Shift+Up/Down might not work.")
    KEY_SHIFT_UP = 567
    KEY_SHIFT_DOWN = 526

# Common terminal sequences for shifted arrows when curses does not decode them.
SHIFT_UP_SEQS = {"\x1b[1;2A", "\x1b[1;2a", "\x1b[a"}
SHIFT_DOWN_SEQS = {"\x1b[1;2B", "\x1b[1;2b", "\x1b[b"}

# Reliable fallback keys for reordering when shifted arrows are not available.
KEY_REORDER_UP_FALLBACK = {ord("K")}
KEY_REORDER_DOWN_FALLBACK = {ord("J")}


def read_escape_sequence(stdscr) -> str:
    """Read immediately available bytes after ESC and return full sequence."""
    seq = [KEY_ESC]
    stdscr.nodelay(True)
    try:
        while len(seq) < 8:
            nxt = stdscr.getch()
            if nxt == -1:
                break
            seq.append(nxt)
    finally:
        stdscr.nodelay(False)
        stdscr.timeout(DEFAULT_INPUT_TIMEOUT_MS)

    try:
        return "".join(chr(ch) for ch in seq if 0 <= ch <= 255)
    except Exception:
        return "\x1b"


def normalize_key(stdscr, key: int) -> int:
    """Normalize raw key input across terminal variants."""
    if key != KEY_ESC:
        return key

    seq = read_escape_sequence(stdscr)
    if seq in SHIFT_UP_SEQS:
        log.debug("mapped escape sequence to Shift+Up: %r", seq)
        return KEY_SHIFT_UP
    if seq in SHIFT_DOWN_SEQS:
        log.debug("mapped escape sequence to Shift+Down: %r", seq)
        return KEY_SHIFT_DOWN

    if seq != "\x1b":
        log.debug("unmapped escape sequence: %r", seq)
    return KEY_ESC


def key_to_action(stdscr, key: int) -> Tuple[str, int | None]:
    """Map a key press to a logical action."""
    norm_key = normalize_key(stdscr, key)

    if norm_key in (KEY_ESC, ord("q")):
        return "quit", None
    if norm_key in KEY_UP:
        return "cursor_up", None
    if norm_key in KEY_DOWN:
        return "cursor_down", None
    if (
        norm_key == KEY_SHIFT_UP
        or norm_key == KEY_LEFT
        or norm_key in KEY_REORDER_UP_FALLBACK
    ):
        return "reorder_up", None
    if (
        norm_key == KEY_SHIFT_DOWN
        or norm_key == KEY_RIGHT
        or norm_key in KEY_REORDER_DOWN_FALLBACK
    ):
        return "reorder_down", None
    if norm_key in KEY_ENTER:
        return "select_current", None
    if norm_key == KEY_CTRL_D:
        return "delete", None
    if 0 <= norm_key <= 255:
        return "select_index", norm_key
    return "noop", None


def clamp_cursor(cursor: int, names: List[str]) -> int:
    """Keep cursor within the visible item range."""
    if not names:
        return 0
    max_index = min(len(names), len(INDEX_CHARS)) - 1
    return max(0, min(cursor, max_index))


def refresh_runtime_state(state: SessionState, refresh_names: bool = False) -> None:
    """Refresh live sessions and current session, optionally rebuilding names."""
    state.live_names = all_live_session_names()
    state.current_name = current_session()
    if refresh_names:
        state.names = build_session_names(state.use_all_sessions, state.live_names)
    state.cursor = clamp_cursor(state.cursor, state.names)


def reorder_sessions(state: SessionState, direction: int) -> bool:
    """Move selected session up/down. Returns True if state changed."""
    num_items = min(len(state.names), len(INDEX_CHARS))
    if num_items <= 1:
        return False

    if direction < 0:
        if state.cursor <= 0:
            return False
        idx = state.cursor
        state.names[idx - 1], state.names[idx] = state.names[idx], state.names[idx - 1]
        state.cursor -= 1
    else:
        if state.cursor >= num_items - 1:
            return False
        idx = state.cursor
        state.names[idx + 1], state.names[idx] = state.names[idx], state.names[idx + 1]
        state.cursor += 1

    save_order(state.use_all_sessions, state.names)
    return True


def delete_current_session(state: SessionState) -> bool:
    """Handle Ctrl+D behavior for current mode. Returns True if state changed."""
    if not (0 <= state.cursor < len(state.names)):
        log.warning("Ctrl+D pressed with invalid cursor position: %d", state.cursor)
        return False

    name_to_delete = state.names[state.cursor]

    if state.use_all_sessions:
        log.info(
            "Ctrl+D pressed in all-sessions mode, killing session %s",
            name_to_delete,
        )
        kill_session(name_to_delete)

        custom_order = load_order(True)
        if name_to_delete in custom_order:
            custom_order.remove(name_to_delete)
            save_order(True, custom_order)

        state.live_names = all_live_session_names()
        state.names = build_session_names(True, state.live_names)
    else:
        log.debug("Ctrl+D pressed, removing bookmark for %s", name_to_delete)
        state.names.pop(state.cursor)

        current_live_names = all_live_session_names()
        if name_to_delete in current_live_names:
            log.info("Session %s is live, killing it.", name_to_delete)
            kill_session(name_to_delete)
        else:
            log.debug("Session %s was not live, only removing bookmark.", name_to_delete)

        save_order(False, state.names)
        state.live_names = current_live_names

    state.current_name = current_session()
    state.cursor = clamp_cursor(state.cursor, state.names)
    return True


def render_session_line(
    stdscr, idx, name, is_live, is_cursor, row, w, is_current=False
):
    """Render a session line in the popup with appropriate colors and formatting."""
    mark = INDEX_CHARS[idx]

    index_pair = curses.color_pair(4 if is_cursor else 3) | curses.A_BOLD

    base_text_pair = curses.color_pair(2 if is_cursor else 1)
    dead_text_pair = curses.color_pair(6 if is_cursor else 5)
    current_text_pair = curses.color_pair(8 if is_cursor else 7)

    try:
        stdscr.addstr(row, 0, mark, index_pair)
    except curses.error:
        pass

    display_name = f"  {name}"
    dead_marker = "   dead"
    current_marker = "   active"

    text_start_col = len(mark)
    available_width = w - text_start_col

    # Display name part
    name_part_len = min(len(display_name), available_width)
    if name_part_len > 0:
        try:
            stdscr.addstr(
                row,
                text_start_col,
                display_name[:name_part_len],
                base_text_pair | (curses.A_BOLD if is_cursor else 0),
            )
        except curses.error:
            pass

    current_col = text_start_col + name_part_len
    remaining_width = w - current_col

    # Display dead marker if needed
    if not is_live and remaining_width > 0:
        dead_part_len = min(len(dead_marker), remaining_width)
        if dead_part_len > 0:
            try:
                stdscr.addstr(
                    row,
                    current_col,
                    dead_marker[:dead_part_len],
                    dead_text_pair | (curses.A_BOLD if is_cursor else 0),
                )
                current_col += dead_part_len
                remaining_width -= dead_part_len
            except curses.error:
                pass

    # Display current marker if needed
    if is_current and remaining_width > 0:
        current_part_len = min(len(current_marker), remaining_width)
        if current_part_len > 0:
            try:
                stdscr.addstr(
                    row,
                    current_col,
                    current_marker[:current_part_len],
                    current_text_pair | (curses.A_BOLD if is_cursor else 0),
                )
                current_col += current_part_len
                remaining_width -= current_part_len
            except curses.error:
                pass

    # Fill remaining space on cursor line
    if is_cursor:
        if remaining_width > 0:
            try:
                stdscr.addstr(row, current_col, " " * remaining_width, base_text_pair)
            except curses.error:
                pass


def curses_main(stdscr):
    """Main function for the curses-based popup interface."""
    use_all_sessions = "--all" in sys.argv

    curses.set_escdelay(ESC_DELAY_MS)
    curses.curs_set(0)
    stdscr.keypad(True)
    stdscr.timeout(DEFAULT_INPUT_TIMEOUT_MS)

    log.debug(
        "input setup: TERM=%s, KEY_SR=%s, KEY_SF=%s, escdelay=%sms",
        os.getenv("TERM", ""),
        KEY_SHIFT_UP,
        KEY_SHIFT_DOWN,
        ESC_DELAY_MS,
    )

    curses.start_color()
    curses.use_default_colors()
    NORMAL_FG, NORMAL_BG = -1, -1
    HILITE_FG, HILITE_BG = -1, 0
    INDEX_FG, INDEX_BG = 11, -1
    DEAD_FG = 242
    CURRENT_FG = 10

    curses.init_pair(1, NORMAL_FG, NORMAL_BG)
    curses.init_pair(2, HILITE_FG, HILITE_BG)
    curses.init_pair(3, INDEX_FG, INDEX_BG)
    curses.init_pair(4, INDEX_FG, HILITE_BG)
    curses.init_pair(5, DEAD_FG, NORMAL_BG)
    curses.init_pair(6, DEAD_FG, HILITE_BG)
    curses.init_pair(7, CURRENT_FG, NORMAL_BG)
    curses.init_pair(8, CURRENT_FG, HILITE_BG)

    stdscr.bkgd(" ", curses.color_pair(1))
    live_names = all_live_session_names()
    state = SessionState(
        use_all_sessions=use_all_sessions,
        names=build_session_names(use_all_sessions, live_names),
        live_names=live_names,
        current_name=current_session(),
    )

    empty_message = no_sessions_message(use_all_sessions)
    needs_redraw = True

    log.debug(
        "Running popup with %s sessions. Use all sessions: %s",
        len(state.names),
        use_all_sessions,
    )

    while True:
        if needs_redraw:
            refresh_runtime_state(state, refresh_names=state.use_all_sessions)

            log.debug("Redrawing popup. Live names: %s", state.live_names)
            stdscr.erase()
            h, w = stdscr.getmaxyx()
            log.debug("curses window size: %dx%d", w, h)

            if not state.names:
                stdscr.addstr(0, 0, empty_message)
            else:
                display_count = min(len(state.names), h, len(INDEX_CHARS))

                for idx in range(display_count):
                    name = state.names[idx]
                    is_live = name in state.live_names
                    is_cursor = idx == state.cursor
                    is_current = name == state.current_name

                    render_session_line(
                        stdscr, idx, name, is_live, is_cursor, idx, w, is_current
                    )

            stdscr.refresh()
            needs_redraw = False

        key = stdscr.getch()

        if key == -1:
            continue

        action, action_value = key_to_action(stdscr, key)
        log.debug("key press: raw=%s action=%s", key, action)

        if action == "quit":
            log.debug("Exit key pressed (ESC or q)")
            return

        if not state.names:
            continue

        num_items = min(len(state.names), len(INDEX_CHARS))

        if action == "select_index":
            if action_value is None:
                continue

            key_char = chr(action_value)
            if key_char in INDEX_CHARS[:num_items]:
                i = INDEX_CHARS.index(key_char)
                if i < len(state.names):
                    name_to_jump = state.names[i]
                    log.debug(
                        "Index char '%s' pressed, jumping to session %s",
                        key_char,
                        name_to_jump,
                    )
                    jump_to_session(name_to_jump)
                    return
            continue

        if action == "cursor_up":
            state.cursor = (state.cursor - 1 + num_items) % num_items
            needs_redraw = True
        elif action == "cursor_down":
            state.cursor = (state.cursor + 1) % num_items
            needs_redraw = True
        elif action == "reorder_up":
            if reorder_sessions(state, -1):
                needs_redraw = True

        elif action == "reorder_down":
            if reorder_sessions(state, 1):
                needs_redraw = True

        elif action == "select_current":
            if 0 <= state.cursor < len(state.names):
                name_to_jump = state.names[state.cursor]
                log.debug("Enter key pressed, jumping to session %s", name_to_jump)
                jump_to_session(name_to_jump)
                return
            log.warning("Enter pressed with invalid cursor position: %d", state.cursor)

        elif action == "delete":
            if delete_current_session(state):
                needs_redraw = True

        elif action == "noop":
            continue

        else:
            log.debug("Unhandled action: %s", action)
            needs_redraw = True


def cmd_popup_inside() -> None:
    """Run the curses interface inside the popup."""
    try:
        curses.wrapper(curses_main)
    except Exception as e:
        log.exception("Critical error within curses wrapper: %s", e)
        try:
            show_status(f"Spine Error: {e}")
        except Exception:
            pass


# ────────────────────────────── main entry ─────────────────────────────── #


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help"]:
        print("Usage: tmux-spine {add|popup|list} [options]", file=sys.stderr)
        print("\nCommands:", file=sys.stderr)
        print("  add      Bookmark the current session", file=sys.stderr)
        print(
            "  popup    Show the interactive session selection popup", file=sys.stderr
        )
        print("  list     List bookmarked sessions to stdout", file=sys.stderr)

        print("\nOptions:", file=sys.stderr)
        print(
            "  --all    Show all live sessions instead of bookmarked ones (with popup)",
            file=sys.stderr,
        )
        print(
            "  --debug  Enable debug logging to ~/.cache/tmux/spine.log",
            file=sys.stderr,
        )
        sys.exit(1)

    cmd = sys.argv[1]
    log.debug("command = %s", cmd)

    try:
        if cmd == "add":
            cmd_add()
        elif cmd == "popup":
            use_all_sessions = "--all" in sys.argv
            launch_popup(use_all_sessions)
        elif cmd == "__inpopup":
            cmd_popup_inside()
        elif cmd == "list":
            cmd_list()
        else:
            print(f"Unknown command: {cmd}", file=sys.stderr)
            print("Use 'tmux-spine --help' for usage.", file=sys.stderr)
            sys.exit(1)

        log.debug("command %s finished successfully", cmd)

    except Exception as e:
        log.exception("An unexpected error occurred during command '%s': %s", cmd, e)

        try:
            show_status(f"Tmux Spine Error ({cmd}): {e}")
        except Exception:
            pass
        sys.exit(1)


if __name__ == "__main__":
    main()
