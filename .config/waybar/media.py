#!/usr/bin/env python3
import gi

gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib
import sys
import threading
import asyncio
import json
import logging
import argparse
import signal
import subprocess
import json

logger = logging.getLogger(__name__)

switching = False


async def run_playerctl(player_manager):
    # Define the command
    command = "playerctl metadata --player playerctld --follow"

    # Using create_subprocess_shell to run the command
    process = await asyncio.create_subprocess_shell(
        command, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )

    # Ensure the process was started successfully
    if process.stdout is None:
        # print("Failed to capture stdout.")
        return

    logger.info("Listening for metadata changes...")

    try:
        # TODO: call the player_changed only once per update, not on every new line (is it even possible?)

        while True:
            line = await process.stdout.readline()
            if not line:
                break  # EOF reached
            decoded_line = line.decode()
            if decoded_line and not switching:
                player_manager.player_changed()
    except asyncio.CancelledError:
        logger.info("Listener was cancelled.")
    finally:
        # Optionally, terminate the subprocess if it's still running
        if process.returncode is None:
            process.terminate()
            await process.wait()

    # Optionally, handle stderr
    stderr = await process.stderr.read()
    if stderr:
        logger.info(f"Error: {stderr.decode().strip()}")


def get_players():
    # Run the command and capture the output
    result = subprocess.run(
        ["playerctl", "--list-all"],
        capture_output=True,  # Captures stdout and stderr
        text=True,  # Decodes bytes to string automatically
        check=True,  # Raises CalledProcessError for non-zero exit codes
    )
    return result.stdout.strip()


def get_active_player():
    try:
        # Run the command and capture the output
        result = subprocess.run(
            ["playerctl", "metadata"],
            capture_output=True,  # Captures stdout and stderr
            text=True,  # Decodes bytes to string automatically
            check=True,  # Raises CalledProcessError for non-zero exit codes
        )

        # Get the standard output as a string
        output = result.stdout.strip()

        if not output:
            logger.info("No output received from the command.")
            return None

        # Split the output into words and get the first one
        first_word = output.split()[0]

        return first_word

    except subprocess.CalledProcessError as e:
        logger.info(f"Command failed with exit code {e.returncode}")
        logger.info(f"Error output: {e.stderr}")
        return None
    except FileNotFoundError:
        logger.info(
            "The 'playerctl' command was not found. Please ensure it is installed and in your PATH."
        )
        return None
    except Exception as e:
        logger.info(f"An unexpected error occurred: {e}")
        return None


class UniqueStack:
    def __init__(self):
        self.stack = []
        self.set = set()

    def top(self):
        if len(self.stack) == 0:
            return None
        return self.stack[-1]

    def push(self, item):
        if item in self.set:
            self.stack.remove(item)
        self.stack.append(item)
        self.set.add(item)

    def pop(self):
        if not self.stack:
            raise IndexError("pop from empty stack")
        item = self.stack.pop()
        self.set.remove(item)
        return item

    def remove(self, item):
        if item in self.set:
            self.stack.remove(item)
            self.set.remove(item)
        else:
            raise ValueError(f"Item '{item}' not found in stack")

    def __contains__(self, item):
        return item in self.set

    def __len__(self):
        return len(self.stack)

    def __repr__(self):
        return f"UniqueStack({self.stack})"

    def __str__(self) -> str:
        s = ""
        for player in self.stack:
            s = player.props.player_name + ", " + s
        return s


def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    sys.exit(0)


class Players:
    def __init__(self):
        self.playing_players = UniqueStack()
        self.paused_players = UniqueStack()
        self.stopped_players = UniqueStack()

    def log_stacks(self):
        logger.debug(f"Playing: {self.playing_players}")
        logger.debug(f"Paused: {self.paused_players}")
        logger.debug(f"Stopped: {self.stopped_players}\n")

    def clean(self):
        players = self.playing_players.set.copy()
        for player in players:
            if player.props.status != "Playing":
                player_name = getattr(player.props, "player_name", "Unknown")
                player_status = getattr(player.props, "status", "Unknown")
                logger.debug(
                    f"Updating player '{player_name}' to status '{player_status}'."
                )

                # Remove player from all stacks first to maintain uniqueness across all states
                for stack_name, stack in [
                    ("playing_players", self.playing_players),
                    ("paused_players", self.paused_players),
                    ("stopped_players", self.stopped_players),
                ]:
                    try:
                        stack.remove(player)
                        logger.info(
                            f"Removed player '{player_name}' from '{stack_name}' stack before adding to new stack."
                        )
                    except ValueError:
                        logger.debug(
                            f"Player '{player_name}' not found in '{stack_name}' stack. No removal necessary."
                        )

                # Add to the new status stack
                try:
                    if player_status == "Playing":
                        self.playing_players.push(player)
                        logger.info(
                            f"Player '{player_name}' updated to 'Playing' and added to 'playing_players' stack."
                        )
                    elif player_status == "Paused":
                        self.paused_players.push(player)
                        logger.info(
                            f"Player '{player_name}' updated to 'Paused' and added to 'paused_players' stack."
                        )
                    elif player_status == "Stopped":
                        self.stopped_players.push(player)
                        logger.info(
                            f"Player '{player_name}' updated to 'Stopped' and added to 'stopped_players' stack."
                        )
                    else:
                        logger.warning(
                            f"Player '{player_name}' has an unrecognized status '{player_status}'. No stack updated."
                        )
                except Exception as e:
                    logger.info(
                        f"Failed to add player '{player_name}' to the '{player_status}' stack: {e}"
                    )

    def get_player(self, name):
        for player in self.playing_players.set:
            if player.props.player_name == name:
                return player
        for player in self.paused_players.set:
            if player.props.player_name == name:
                return player
        for player in self.stopped_players.set:
            if player.props.player_name == name:
                return player
        logger.info(f"get_player(): Player {name} not found")
        return None

    def add_player_to_top(self, player):
        if player == self.top():
            logger.debug(f"Player {player.props.player_name} is already at the top")
            return

        # if there were any other manually added players to the top clean them
        self.clean()

        player_name = getattr(player.props, "player_name", "Unknown")
        player_status = getattr(player.props, "status", "Unknown")
        logger.debug(
            f"Attempting to add player '{player_name}' with status '{player_status}'."
        )
        # Remove player from all stacks first to maintain uniqueness across all states
        for stack_name, stack in [
            ("playing_players", self.playing_players),
            ("paused_players", self.paused_players),
            ("stopped_players", self.stopped_players),
        ]:
            try:
                stack.remove(player)
                logger.info(
                    f"Removed player '{player_name}' from '{stack_name}' stack before adding to new stack."
                )
            except ValueError:
                logger.debug(
                    f"Player '{player_name}' not found in '{stack_name}' stack. No removal necessary."
                )

        self.playing_players.push(player)
        logger.info(f"Added player '{player_name}' to the top of the stack")

    def add_player(self, player):
        player_name = getattr(player.props, "player_name", "Unknown")
        player_status = getattr(player.props, "status", "Unknown")
        logger.debug(
            f"Attempting to add player '{player_name}' with status '{player_status}'."
        )

        # Remove player from all stacks first to maintain uniqueness across all states
        for stack_name, stack in [
            ("playing_players", self.playing_players),
            ("paused_players", self.paused_players),
            ("stopped_players", self.stopped_players),
        ]:
            try:
                stack.remove(player)
                logger.info(
                    f"Removed player '{player_name}' from '{stack_name}' stack before adding to new stack."
                )
            except ValueError:
                logger.debug(
                    f"Player '{player_name}' not found in '{stack_name}' stack. No removal necessary."
                )

        # Now add to the appropriate stack
        if player_status == "Playing":
            self.playing_players.push(player)
            logger.info(f"Added player '{player_name}' to the 'playing_players' stack.")
        elif player_status == "Paused":
            self.paused_players.push(player)
            logger.info(f"Added player '{player_name}' to the 'paused_players' stack.")
        elif player_status == "Stopped":
            self.stopped_players.push(player)
            logger.info(f"Added player '{player_name}' to the 'stopped_players' stack.")
        else:
            logger.warning(
                f"Player '{player_name}' has an unrecognized status '{player_status}'. No stack added."
            )
        self.set_as_active(self.top())

    def remove_player(self, player):
        player_name = getattr(player.props, "player_name", "Unknown")
        logger.debug(f"Attempting to remove player '{player_name}' from all stacks.")

        removed = False
        for stack_name, stack in [
            ("playing_players", self.playing_players),
            ("paused_players", self.paused_players),
            ("stopped_players", self.stopped_players),
        ]:
            try:
                stack.remove(player)
                logger.info(
                    f"Removed player '{player_name}' from '{stack_name}' stack."
                )
                removed = True
            except ValueError:
                logger.debug(
                    f"Player '{player_name}' not found in '{stack_name}' stack."
                )

        if not removed:
            logger.info(f"Error: Player '{player_name}' not found in any stack.")

        # if it is the last player there is no top
        top = self.top()
        if top != None:
            self.set_as_active(top)

    def update_player(self, player):
        player_name = getattr(player.props, "player_name", "Unknown")
        player_status = getattr(player.props, "status", "Unknown")
        logger.debug(f"Updating player '{player_name}' to status '{player_status}'.")

        # Remove player from all stacks first to maintain uniqueness across all states
        for stack_name, stack in [
            ("playing_players", self.playing_players),
            ("paused_players", self.paused_players),
            ("stopped_players", self.stopped_players),
        ]:
            try:
                stack.remove(player)
                logger.info(
                    f"Removed player '{player_name}' from '{stack_name}' stack before adding to new stack."
                )
            except ValueError:
                logger.debug(
                    f"Player '{player_name}' not found in '{stack_name}' stack. No removal necessary."
                )

        # Add to the new status stack
        try:
            if player_status == "Playing":
                self.playing_players.push(player)
                logger.info(
                    f"Player '{player_name}' updated to 'Playing' and added to 'playing_players' stack."
                )
            elif player_status == "Paused":
                self.paused_players.push(player)
                logger.info(
                    f"Player '{player_name}' updated to 'Paused' and added to 'paused_players' stack."
                )
            elif player_status == "Stopped":
                self.stopped_players.push(player)
                logger.info(
                    f"Player '{player_name}' updated to 'Stopped' and added to 'stopped_players' stack."
                )
            else:
                logger.warning(
                    f"Player '{player_name}' has an unrecognized status '{player_status}'. No stack updated."
                )
        except Exception as e:
            logger.info(
                f"Failed to add player '{player_name}' to the '{player_status}' stack: {e}"
            )

        self.set_as_active(self.top())

    def top(self):
        top = self.playing_players.top()
        if top == None:
            top = self.paused_players.top()
            if top == None:
                top = self.stopped_players.top()
                if top == None:
                    logger.info(f"Error: NO TOP")
                    return None
        logger.debug(f"TOP STACK: {top.props.player_name}")
        logger.debug(f"ACTIVE PLAYER: {get_active_player()}")
        return top

    # set a player as the active playerctl player
    def set_as_active(self, player):
        global switching
        switching = True
        logger.debug(f"Setting active player: {player.props.player_name}")
        active_player = get_active_player()
        if active_player == None:
            logger.debug(f"No current active players")
            return None
        max = 10
        while (active_player != player.props.player_name) and max >= 0:
            logger.debug(
                f"Currently active player: {active_player}, searching for {player.props.player_name}. Shifting..."
            )
            subprocess.run(["playerctld", "shift"])
            max = max - 1
        if max < 0:
            logger.info(
                f"Done searching, originally searching for {player.props.player_name}. NOT FOUND"
            )
            logger.info(f"Active players: {get_players()}")
        else:
            logger.debug(
                f"Done searching, set active player: {active_player}, originally searching for {player.props.player_name}"
            )
        switching = False


class PlayerManager:
    def run(self):
        logger.info("Starting main loop")
        self.loop.run()

    def __init__(self, player_info=False):
        self.player_info = player_info
        # initialization stuff
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()

        # for every player, (already active or future) add a function that runs when it appears or vanishes
        self.manager.connect(
            "name-appeared", lambda *args: self.on_player_appeared(*args)
        )
        self.manager.connect(
            "player-vanished", lambda *args: self.on_player_vanished(*args)
        )

        self.players = Players()

        # command handling
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)

        # initialize the already active players if there are any
        for player in self.manager.props.player_names:
            self.init_player(player)

    # the current active player has changed, so we have to find the current active player in the players and set it to the top
    # even though it might not be playing
    def player_changed(self):
        logger.debug("The currently active player has changed")
        current_active_player = get_active_player()
        if current_active_player == None:
            logger.info("No active players found to switch to. WTF")
            return None
        active_player = self.players.get_player(current_active_player)
        if active_player == None:
            logger.info(f"No players found with name: {current_active_player}")
            return None

        # put this player on the top
        self.players.add_player_to_top(active_player)
        self.on_metadata_changed(active_player)

    # initialize a player
    def init_player(self, player):
        logger.info(f"Initializing player: {player.name}")
        player = Playerctl.Player.new_from_name(player)
        logger.info(f"Player is currently: {player.props.status}")

        # give the player callbacks for status changed an metadata changed
        player.connect("playback-status", self.on_playback_status_changed, None)
        player.connect("metadata", self.on_metadata_changed, None)

        # not sure but this makes the callbacks work
        self.manager.manage_player(player)

        # add to the players
        self.players.add_player(player)

    def on_player_appeared(self, _, player):
        logger.info(f"Player has appeared: {player}")
        self.init_player(player)

    def on_player_vanished(self, _, player):
        logger.info(f"Player has vanished: {player.props.player_name}")
        self.players.remove_player(player)
        self.on_metadata_changed(player)

    def on_metadata_changed(self, player, metadata=None, _=None):
        logger.info(f"Metadata  has changed for player: {player.props.player_name}")

        # print the output of the player on top
        player = self.players.top()
        if player == None:
            self.clear_output()
            return

        player_name = player.props.player_name
        artist = player.get_artist()
        title = player.get_title()

        player_icon = ""
        if player_name == "spotify":
            player_icon = ""
        elif player_name == "chromium":
            player_icon = "󰊯"
        elif player_name == "vlc":
            player_icon = "󰕼"
        else:
            player_icon = "󰎅"

        track_info = ""
        if artist is not None and title is not None and artist != "" and title != "":
            track_info = f"{title} - {artist}"
        elif title is not None and title != "":
            track_info = f"{title}"
        else:
            self.clear_output()
            return

        state = ""
        if track_info:
            if player.props.status == "Playing":
                state = "󰺢"
            else:
                state = ""

        if self.player_info:
            self.write_output(player_icon, player_icon)
        else:
            self.write_output(truncate(track_info, 20), f"{player_icon}    {state}")

    def on_playback_status_changed(self, player, status, _=None):
        logger.info(
            f"Playback status changed for player: {player.props.player_name}. New status: {status}"
        )
        self.players.update_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def write_output(self, text, player_and_state):
        logger.debug(f"Writing output: {text}")

        output = {
            "text": text,
            "class": "custom-media",
            "alt": player_and_state,
        }

        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        logger.debug("Clearing output")
        sys.stdout.write("\n")
        sys.stdout.flush()


def parse_arguments():
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)

    parser.add_argument("--enable-logging", action="store_true")
    parser.add_argument("--player-info", action="store_true")

    return parser.parse_args()


def start_playerctl(player):
    asyncio.run(run_playerctl(player))


def main():
    arguments = parse_arguments()

    if arguments.enable_logging:
        logging.basicConfig(
            stream=sys.stdout,
            level=logging.DEBUG,
            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s",
        )

    logger.setLevel("DEBUG")

    logger.info("Creating player manager")
    player = PlayerManager(arguments.player_info)

    # Start the run_playerctl coroutine in a separate daemon thread
    playerctl_thread = threading.Thread(
        target=start_playerctl, args=(player,), daemon=True
    )
    playerctl_thread.start()
    logger.debug("Started run_playerctl in a separate thread.")

    # Run the GLib main loop
    player.run()


def truncate(text: str, length: int) -> str:
    if len(text) <= length:
        return text
    return text[: length - 3] + "..."


def wrap_icon(icon: str) -> str:
    # return f"<span font-weight='normal'>{icon}</span>"
    return icon


if __name__ == "__main__":
    main()
