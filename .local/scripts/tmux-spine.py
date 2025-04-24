#!/usr/bin/env python3

from __future__ import annotations

import curses
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

STORE_FILE = pathlib.Path(
    os.getenv(
        "TMUX_SPINE_FILE",
        os.path.join(
            os.getenv("XDG_CONFIG_HOME", os.path.expanduser("~/.config")),
            "tmux",
            "spine",
            "sessions",
        ),
    )
)

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
HEIGHT_PADDING = 3

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


# ────────────────────────── session formatting ──────────────────────────── #


def format_session_line(idx: int, name: str, is_live: bool) -> str:
    """Format session line for display with index character and live/dead status."""
    mark = INDEX_CHARS[idx]
    dead_marker = "  ( dead)" if not is_live else ""
    return f"{mark} {name}{dead_marker}"


# ───────────────────────────── add command ──────────────────────────────── #


def cmd_add() -> None:
    """Add the current session name to the top of the bookmarks."""
    current_name = current_session()
    if not current_name:
        log.error("Could not get current session name.")
        show_status("Error: Could not get current session name.")
        return

    names = load_store()
    names = [n for n in names if n != current_name]
    names.append(current_name)
    save_store(names)
    show_status(f"[Tmux Spine] Session added to the list.")


# ───────────────────────────── list command ─────────────────────────────── #


def cmd_list() -> None:
    """List bookmarked sessions, indicating liveness and assigned index char."""
    names = load_store()
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


def calculate_popup_dimensions() -> Tuple[int, int]:
    """Calculate appropriate dimensions for the popup based on content."""
    names = load_store()
    live_names = all_live_session_names()

    if not names:
        content_width = len("No bookmarked sessions. Press Esc/q.")
        content_height = 1
    else:
        max_line_len = 0
        limited_names = names[: len(INDEX_CHARS)]
        for idx, name in enumerate(limited_names):
            line = format_session_line(idx, name, name in live_names)
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


def launch_popup() -> None:
    """Launch popup with dynamically calculated dimensions."""
    width, height = calculate_popup_dimensions()
    popup_opts = f"{POPUP_BASE_OPTS} -w {width} -h {height}"

    script_path_arg = shlex.quote(sys.argv[0])
    debug_arg = " --debug" if DEBUG_ENABLED else ""
    popup_cmd = f"display-popup {popup_opts} {script_path_arg} __inpopup{debug_arg}"

    tmx(popup_cmd)


KEY_ENTER = {curses.KEY_ENTER, 10, 13}
KEY_CTRL_D = 4
KEY_ESC = 27
KEY_UP = {curses.KEY_UP, ord("k")}
KEY_DOWN = {curses.KEY_DOWN, ord("j")}
# Try to get correct Shift+Up/Down codes if available
try:
    KEY_SHIFT_UP = curses.KEY_SR
    KEY_SHIFT_DOWN = curses.KEY_SF
except AttributeError:
    log.warning("curses.KEY_SR/SF not available, Shift+Up/Down might not work.")
    KEY_SHIFT_UP = 567
    KEY_SHIFT_DOWN = 526


def render_session_line(stdscr, idx, name, is_live, is_cursor, row, w):
    """Render a session line in the popup with appropriate colors and formatting."""
    mark = INDEX_CHARS[idx]

    index_pair = curses.color_pair(4 if is_cursor else 3) | curses.A_BOLD

    base_text_pair = curses.color_pair(2 if is_cursor else 1)
    dead_text_pair = curses.color_pair(6 if is_cursor else 5)

    try:
        stdscr.addstr(row, 0, mark, index_pair)
    except curses.error:
        pass

    display_name = f"  {name}"
    dead_marker = "  ( dead)"
    full_text = display_name + (dead_marker if not is_live else "")

    text_start_col = len(mark)
    available_width = w - text_start_col

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

    if not is_live:
        dead_start_col = text_start_col + name_part_len
        available_width_for_dead = w - dead_start_col
        dead_part_len = min(len(dead_marker), available_width_for_dead)
        if dead_part_len > 0:
            try:
                stdscr.addstr(
                    row,
                    dead_start_col,
                    dead_marker[:dead_part_len],
                    dead_text_pair | (curses.A_BOLD if is_cursor else 0),
                )
            except curses.error:
                pass

    if is_cursor:
        fill_start_col = text_start_col + min(len(full_text), available_width)
        fill_len = w - fill_start_col
        if fill_len > 0:
            try:
                stdscr.addstr(row, fill_start_col, " " * fill_len, base_text_pair)
            except curses.error:
                pass


def curses_main(stdscr):
    """Main function for the curses-based popup interface."""
    curses.set_escdelay(25)
    curses.curs_set(0)
    stdscr.keypad(True)
    stdscr.timeout(25)

    curses.start_color()
    curses.use_default_colors()
    NORMAL_FG, NORMAL_BG = -1, -1
    HILITE_FG, HILITE_BG = -1, 0
    INDEX_FG, INDEX_BG = 11, -1
    DEAD_FG = 242

    curses.init_pair(1, NORMAL_FG, NORMAL_BG)
    curses.init_pair(2, HILITE_FG, HILITE_BG)
    curses.init_pair(3, INDEX_FG, INDEX_BG)
    curses.init_pair(4, INDEX_FG, HILITE_BG)
    curses.init_pair(5, DEAD_FG, NORMAL_BG)
    curses.init_pair(6, DEAD_FG, HILITE_BG)

    stdscr.bkgd(" ", curses.color_pair(1))

    names = load_store()
    cursor = 0
    needs_redraw = True

    while True:
        if needs_redraw:
            live_names = all_live_session_names()
            log.debug("Redrawing popup. Live names: %s", live_names)
            stdscr.erase()
            h, w = stdscr.getmaxyx()
            log.debug("curses window size: %dx%d", w, h)

            if not names:
                stdscr.addstr(0, 0, "No bookmarked sessions. Press Esc/q.")
            else:
                display_count = min(len(names), h, len(INDEX_CHARS))

                for idx in range(display_count):
                    name = names[idx]
                    is_live = name in live_names
                    is_cursor = idx == cursor

                    render_session_line(stdscr, idx, name, is_live, is_cursor, idx, w)

            stdscr.refresh()
            needs_redraw = False

        key = stdscr.getch()

        if key == -1:
            continue

        log.debug("key press: %s", key)

        if key in (KEY_ESC, ord("q")):
            log.debug("Exit key pressed (ESC or q)")
            return

        if not names:
            continue

        num_items = min(len(names), len(INDEX_CHARS))

        if 0 <= key <= 255 and chr(key) in INDEX_CHARS[:num_items]:
            try:
                i = INDEX_CHARS.index(chr(key))
                name_to_jump = names[i]
                log.debug(
                    "Index char '%s' pressed, jumping to session %s",
                    chr(key),
                    name_to_jump,
                )
                jump_to_session(name_to_jump)
                return
            except IndexError:
                log.warning("Index char maps to out-of-bounds name index.")
            except ValueError:
                log.error("Could not find index for character %s", chr(key))
            continue

        elif key in KEY_UP:
            cursor = (cursor - 1 + num_items) % num_items
            needs_redraw = True
        elif key in KEY_DOWN:
            cursor = (cursor + 1) % num_items
            needs_redraw = True

        elif key == KEY_SHIFT_UP and cursor > 0:
            names[cursor - 1], names[cursor] = names[cursor], names[cursor - 1]
            cursor -= 1
            save_store(names)
            needs_redraw = True
        elif key == KEY_SHIFT_DOWN and cursor < num_items - 1:
            names[cursor + 1], names[cursor] = names[cursor], names[cursor + 1]
            cursor += 1
            save_store(names)
            needs_redraw = True

        elif key in KEY_ENTER:
            if 0 <= cursor < len(names):
                name_to_jump = names[cursor]
                log.debug("Enter key pressed, jumping to session %s", name_to_jump)
                jump_to_session(name_to_jump)
                return
            else:
                log.warning("Enter pressed with invalid cursor position: %d", cursor)

        elif key == KEY_CTRL_D:
            if 0 <= cursor < len(names):
                name_to_delete = names.pop(cursor)
                log.debug("Ctrl+D pressed, removing bookmark for %s", name_to_delete)

                current_live_names = all_live_session_names()
                if name_to_delete in current_live_names:
                    log.info("Session %s is live, killing it.", name_to_delete)
                    kill_session(name_to_delete)
                else:
                    log.debug(
                        "Session %s was not live, only removing bookmark.",
                        name_to_delete,
                    )

                save_store(names)

                num_items = min(len(names), len(INDEX_CHARS))
                if not names:
                    cursor = 0
                elif cursor >= num_items:
                    cursor = max(0, num_items - 1)

                needs_redraw = True
            else:
                log.warning("Ctrl+D pressed with invalid cursor position: %d", cursor)


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
        print("Usage: tmux-spine {add|popup|list} [--debug]", file=sys.stderr)
        print("\nCommands:", file=sys.stderr)
        print("  add      Bookmark the current session", file=sys.stderr)
        print(
            "  popup    Show the interactive session selection popup", file=sys.stderr
        )
        print("  list     List bookmarked sessions to stdout", file=sys.stderr)

        print("\nOptions:", file=sys.stderr)
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
            launch_popup()
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
