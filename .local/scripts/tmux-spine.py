#!/usr/bin/env python3
"""
tmux-spine: bookmark tmux sessions and jump to them quickly.

🔎 2025-04-24  – v1.2  (debug-enabled)
------------------------------------------------
* Esc key now closes instantly (Esc-delay 25 ms)
* Jumps call `tmux-sessionizer <name>` first, fallback to `tmux`.
* NEW: runtime–toggleable **debug mode**
    ‣ Enable with CLI flag  `--debug` **or** env var `TMUX_SPINE_DEBUG=1`.
    ‣ Detailed trace is written to  `$XDG_CACHE_HOME/tmux/spine.log`
      (falls back to `~/.cache/tmux/spine.log`).

Usage
-----
  tmux-spine add [--debug]
  tmux-spine popup [--debug]
  tmux-spine list [--debug]

Other command-line args remain unchanged, so your tmux key bindings
still work.  Add `--debug` *temporarily* when you need extra insight.
"""

from __future__ import annotations

import curses
import logging
import os
import pathlib
import shlex
import subprocess
import sys
from typing import List, Tuple

# ────────────────────────────── debug / logging ─────────────────────────── #

DEBUG_ENABLED = (
    os.getenv("TMUX_SPINE_DEBUG") in {"1", "true", "yes"} or "--debug" in sys.argv
)

if "--debug" in sys.argv:
    sys.argv.remove("--debug")  # strip so the rest of the parser is clean

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

POPUP_OPTS = os.getenv(
    "TMUX_SPINE_POPUP_OPTS",
    '-w 20% -h 30% -E -b rounded -T "#[align=centre fg=blue bold] Tmux Spine"',
)

NORMAL_FG = 250  # light grey
NORMAL_BG = 57  # deep purple
HILITE_FG = 0  # black
HILITE_BG = 170  # orchid

# ───────────────────────────── tmux helpers ─────────────────────────────── #


def tmx(cmd: str) -> str:
    """Run *tmux cmd* and return stdout (empty string on error)."""
    log.debug("tmux %s", cmd)
    cp = subprocess.run(
        ["tmux"] + shlex.split(cmd),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if cp.stderr and DEBUG_ENABLED:
        log.debug("tmux-stderr: %s", cp.stderr.strip())
    return cp.stdout.rstrip("\n")


def current_session() -> Tuple[str, str]:
    name = tmx("display -p '#S'")
    sid = tmx("display -p '#{session_id}'")
    log.debug("current session: %s (%s)", name, sid)
    return name, sid


def all_live_session_ids() -> set[str]:
    ids = set(tmx("list-sessions -F '#{session_id}'").splitlines())
    log.debug("live session ids: %s", ids)
    return ids


def jump_to_session(name: str, sid: str) -> None:
    """Switch to *name* using external sessionizer, else tmux fallback."""
    log.info("jump → %s (%s)", name, sid)
    res = subprocess.run(["tmux-sessionizer", name], capture_output=True, text=True)
    if res.returncode != 0:
        log.debug("sessionizer failed (%s) – falling back", res.returncode)
        tmx(f"switch-client -t {sid}")


def kill_session(sid: str) -> None:
    log.info("kill session %s", sid)
    tmx(f"kill-session -t {sid}")


def show_status(msg: str) -> None:
    tmx(f"display-message {shlex.quote(msg)}")


# ───────────────────────────── data storage ─────────────────────────────── #


def load_store() -> List[Tuple[str, str]]:
    if not STORE_FILE.exists():
        log.debug("store file missing – returning empty list")
        return []
    rows: List[Tuple[str, str]] = []
    for ln in STORE_FILE.read_text().splitlines():
        if "\t" in ln:
            n, i = ln.split("\t", 1)
            rows.append((n, i))
    log.debug("loaded store: %s", rows)
    return rows


def save_store(rows: List[Tuple[str, str]]) -> None:
    STORE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with STORE_FILE.open("w") as fh:
        for n, i in rows[: len(INDEX_CHARS)]:
            fh.write(f"{n}\t{i}\n")
    log.debug("saved store (%d entries)", len(rows))


# ───────────────────────────── add command ──────────────────────────────── #


def cmd_add() -> None:
    name, sid = current_session()
    rows = [(n, i) for n, i in load_store() if n != name and i != sid]
    rows.insert(0, (name, sid))
    save_store(rows)
    show_status(f"★ Bookmarked session: {name}")


# ───────────────────────────── list command ─────────────────────────────── #


def cmd_list() -> None:
    rows = load_store()
    live = all_live_session_ids()
    for idx, (n, sid) in enumerate(rows):
        mark = INDEX_CHARS[idx] if idx < len(INDEX_CHARS) else "?"
        dead = " (DEAD)" if sid not in live else ""
        print(f"{mark} {n}{dead}")


# ───────────────────────────── popup command ────────────────────────────── #


def launch_popup() -> None:
    tmx(
        f"display-popup {POPUP_OPTS} {shlex.quote(sys.argv[0])} __inpopup"
        + (" --debug" if DEBUG_ENABLED else "")
    )


KEY_ENTER = {curses.KEY_ENTER, 10, 13}
KEY_CTRL_D = 4
KEY_ESC = 27
KEY_UP = {curses.KEY_UP, ord("k")}
KEY_DOWN = {curses.KEY_DOWN, ord("j")}
KEY_SHIFT_UP = 337  # KEY_SR
KEY_SHIFT_DOWN = 336  # KEY_SF


def curses_main(stdscr):
    curses.set_escdelay(25)
    curses.curs_set(0)
    stdscr.keypad(True)
    stdscr.timeout(25)

    NORMAL_FG, NORMAL_BG = -1, -1
    HILITE_FG, HILITE_BG = -1, 0
    INDEX_FG, INDEX_BG = 11, -1

    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, NORMAL_FG, NORMAL_BG)  # normal rows
    curses.init_pair(2, HILITE_FG, HILITE_BG)  # highlighted row
    curses.init_pair(3, INDEX_FG, INDEX_BG)  # index (not highlighted)
    curses.init_pair(4, INDEX_FG, HILITE_BG)  # index (highlighted)
    stdscr.bkgd(" ", curses.color_pair(1))  # whole window bg

    rows = load_store()
    live = all_live_session_ids()
    cursor = 0

    def redraw():
        stdscr.erase()
        _, w = stdscr.getmaxyx()
        if not rows:
            stdscr.addstr(0, 0, "No bookmarked sessions. Press Esc/q.")
            stdscr.refresh()
            return

        for idx, (name, sid) in enumerate(rows):
            mark = INDEX_CHARS[idx] if idx < len(INDEX_CHARS) else "?"
            index_text = f"{mark}"
            rest_text = f" {name}" + (" (dead)" if sid not in live else "")

            # For normal rows
            if idx == cursor:
                # Cursor row
                stdscr.addstr(
                    idx, 0, index_text, curses.color_pair(4) | curses.A_BOLD
                )  # Special index color for selected row
                stdscr.addstr(
                    idx,
                    len(index_text),
                    rest_text.ljust(w - len(index_text)),
                    curses.color_pair(2) | curses.A_BOLD,
                )
            else:
                # Non-cursor row
                stdscr.addstr(
                    idx, 0, index_text, curses.color_pair(3) | curses.A_BOLD
                )  # Special index color
                stdscr.addstr(
                    idx,
                    len(index_text),
                    rest_text.ljust(w - len(index_text)),
                    curses.color_pair(1) | curses.A_BOLD,
                )

        stdscr.refresh()

    stdscr.refresh()
    redraw()

    while True:
        key = stdscr.getch()
        log.debug("key press: %s", key)

        if 0 <= key <= 255 and chr(key) in INDEX_CHARS[: len(rows)]:
            i = INDEX_CHARS.index(chr(key))
            name, sid = rows[i]
            jump_to_session(name, sid)
            return

        if key in KEY_UP:
            cursor = (cursor - 1) % len(rows)
            redraw()
            continue
        if key in KEY_DOWN:
            cursor = (cursor + 1) % len(rows)
            redraw()
            continue

        if key == KEY_SHIFT_UP and cursor > 0:
            rows[cursor - 1], rows[cursor] = rows[cursor], rows[cursor - 1]
            cursor -= 1
            save_store(rows)
            redraw()
            continue
        if key == KEY_SHIFT_DOWN and cursor < len(rows) - 1:
            rows[cursor + 1], rows[cursor] = rows[cursor], rows[cursor + 1]
            cursor += 1
            save_store(rows)
            redraw()
            continue

        if key in KEY_ENTER and rows:
            name, sid = rows[cursor]
            jump_to_session(name, sid)
            return

        if key == KEY_CTRL_D and rows:
            dead = rows.pop(cursor)
            if dead[1] in live:
                kill_session(dead[1])
            save_store(rows)
            cursor = min(cursor, len(rows) - 1)
            redraw()
            continue

        if key in (KEY_ESC, ord("q")):
            return


def cmd_popup_inside() -> None:
    curses.wrapper(curses_main)


# ────────────────────────────── main entry ─────────────────────────────── #


def main():
    if len(sys.argv) < 2:
        print("Usage: tmux-spine {add|popup|list} [--debug]", file=sys.stderr)
        sys.exit(1)

    cmd = sys.argv[1]
    log.debug("command = %s", cmd)

    if cmd == "add":
        cmd_add()
    elif cmd == "popup":
        launch_popup()
    elif cmd == "__inpopup":
        cmd_popup_inside()
    elif cmd == "list":
        cmd_list()
    else:
        print(f"Unknown command {cmd}", file=sys.stderr)
        sys.exit(1)

    log.debug("command %s finished", cmd)


if __name__ == "__main__":
    main()
