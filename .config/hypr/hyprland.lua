-- Hyprland Lua configuration.
-- Converted manually from hyprland.conf for Hyprland 0.56.

------------------
---- PLUGINS ----
------------------

-- The old split-monitor-workspaces C++ plugin configuration was:
-- plugin {
--     split-monitor-workspaces {
--         count = 10
--         keep_focused = 0
--         enable_notifications = 0
--         enable_persistent_workspaces = 0
--     }
-- }
-- No split-monitor-workspaces installation exists in ~/.config/hypr/plugins.
-- Keep this documented until that plugin is installed as its Lua package.

----------------
---- MONITORS ----
----------------

hl.monitor({
	output = "DP-5",
	mode = "3440x1440@100",
	position = "0x0",
	scale = 1.333333,
})

hl.monitor({
	output = "HDMI-A-2",
	mode = "1920x1080@60",
	position = "2580x270",
	scale = 1.2,
})

-- Main monitor without scaling:
-- hl.monitor({ output = "DP-5", mode = "3440x1440@100", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60", position = "3440x320", scale = 1.2 })

-- Unscale XWayland.
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

-------------------
---- MY PROGRAMS ----
-------------------

local terminal = "kitty"
local fileManager = "yazi"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- hl.exec_cmd("hyprpanel")
	-- hl.exec_cmd("quickshell -p /home/marco/shell/shell.qml")
	hl.exec_cmd("caelestia shell -d")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("sleep 2 && /home/marco/go/bin/wallman random")
	hl.exec_cmd("hyprsunset")

	hl.exec_cmd("~/.local/scripts/x11-clipboard-to-wayland.sh")

	-- Hyprland plugins.
	hl.exec_cmd("hyprpm reload -n")

	-- Clipboard history with cliphist.
	hl.exec_cmd("wl-paste --watch cliphist store")

	hl.exec_cmd("playerctl --player playerctld play")

	-- hl.exec_cmd("walker --gapplication-service")
	-- Update systemd environment variables so they reach elephant.
	-- Programs assigned to workspaces in the legacy config.
	-- hl.exec_cmd("QT_QPA_PLATFORM=xcb whatsie", { workspace = 8, silent = true })
	hl.exec_cmd("zen-browser", { workspace = 2 })
	hl.exec_cmd("sleep 10 && spotify-launcher", { workspace = 7 })
	hl.exec_cmd(
		"kitty --start-as=fullscreen -e zsh -c 'source ~/.zshrc && tmux-sessionizer dotfiles'",
		{ workspace = 1 }
	)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("XCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("GDK_SCALE", "1.333333")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("OGL_DEDICATED_HW_STATE_PER_CONTEXT", "ENABLE_ROBUST")
hl.env("TERM", "kitty")
-- hl.env("QT_SCREEN_SCALE_FACTORS", "DP-5=1.333333;HDMI-A-2=1.2")

-----------------------
----- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 8,
		border_size = 0,
		col = {
			active_border = "rgba(353535ff)",
			inactive_border = "rgba(222222ff)",
		},
		resize_on_border = true,
		allow_tearing = true,
		layout = "dwindle",
	},
	cursor = {
		no_hardware_cursors = true,
	},
	decoration = {
		rounding = 20, -- Similar to shell outside corner radius.
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 15,
			render_power = 5,
			color = "rgba(1a1a1aaa)",
		},
		blur = {
			new_optimizations = true,
			enabled = true,
			size = 1,
			passes = 6,
			-- vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		-- pseudotile = true
		preserve_split = true,
		force_split = 2,
	},
	master = {
		new_status = "master",
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

-------------------
---- ANIMATIONS ----
-------------------

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.05 } } })
hl.curve("shot", { type = "bezier", points = { { 0.2, 1.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "shot", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeDim", enabled = false, speed = 1, bezier = "default" })
hl.animation({ leaf = "fadeSwitch", enabled = false, speed = 1, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "overshot", style = "slidevert" })
-- hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "overshot", style = "slide bottom" })

----------------
---- INPUT ----
----------------

hl.config({
	input = {
		kb_layout = "it",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = -0.45,
		touchpad = {
			natural_scroll = false,
		},
		repeat_delay = 200,
		repeat_rate = 50,
	},
})

---------------------
---- WINDOW RULES ----
---------------------

local function window_rule(rule)
	return hl.window_rule(rule)
end

window_rule({ match = { title = "^(Wine Desktop)$" }, immediate = true })
window_rule({ match = { class = "^(gamescope)$" }, immediate = true, float = true })
window_rule({ match = { class = "^thunar$", fullscreen = false }, opacity = 0.85 })
window_rule({ match = { class = "^google-chrome$", fullscreen = false }, opacity = 0.9 })
window_rule({ match = { title = "^WhatsApp Web$", fullscreen = false }, opacity = 0.9 })
window_rule({ match = { class = "^WhatSie$", fullscreen = false }, opacity = 0.9 })
window_rule({ match = { class = "^spotify$", fullscreen = false }, opacity = 0.9 })
window_rule({ match = { class = "^steam$", fullscreen = false }, opacity = 0.9 })
window_rule({ match = { class = "^vesktop$", fullscreen = false }, opacity = 0.9 })
window_rule({ match = { class = "^jetbrains-studio$", fullscreen = false }, opacity = 0.9 })
-- window_rule({ match = { class = "Waydroid", fullscreen = false }, float = true })

hl.layer_rule({
	name = "layerrule-1",
	match = { namespace = "^wofi$" },
	blur = true,
	ignore_alpha = 0,
	dim_around = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

local function bind(key, dispatcher)
	hl.bind(mainMod .. " + " .. key, dispatcher)
end

bind("W", hl.dsp.exec_cmd("hyprpanel restart"))
bind("G", hl.dsp.exec_cmd("zen-browser"))
bind("B", hl.dsp.exec_cmd("/home/marco/go/bin/wallman random"))
hl.bind("ALT + SHIFT + B", hl.dsp.exec_cmd("/home/marco/go/bin/wallman previous"))
bind("F", hl.dsp.window.fullscreen())
bind("L", hl.dsp.exec_cmd("hyprlock"))
bind("Return", hl.dsp.exec_cmd(terminal .. " -e zsh -c 'source ~/.zshrc && tmux-sessionizer dotfiles'"))
hl.bind("ALT + SHIFT + Return", hl.dsp.exec_cmd(terminal))
bind("M", hl.dsp.exec_cmd(fileManager))
bind("Q", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("ALT + SHIFT + M", hl.dsp.exit())
bind("J", hl.dsp.window.float({ action = "toggle" }))
bind("space", hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
bind("P", hl.dsp.window.pseudo())
bind("ALT + CTRL + O", hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | tesseract stdin stdout 2>/dev/null | wl-copy']]))

-- Move focus with mainMod + arrow keys.
bind("left", hl.dsp.focus({ direction = "l" }))
bind("right", hl.dsp.focus({ direction = "r" }))
bind("up", hl.dsp.focus({ direction = "u" }))
bind("down", hl.dsp.focus({ direction = "d" }))

-- Resize window while holding the key.
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

-- Move window.
bind("CONTROL + left", hl.dsp.window.move({ direction = "l" }))
bind("CONTROL + right", hl.dsp.window.move({ direction = "r" }))
bind("CONTROL + up", hl.dsp.window.move({ direction = "u" }))
bind("CONTROL + down", hl.dsp.window.move({ direction = "d" }))

-- "Minimize" window (works with only one at a time).
bind("D", function()
	hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
	hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
	hl.dispatch(hl.dsp.window.move({ workspace = "special:magic" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
end)

-- Switch to workspace.
local workspaceKeys = { n = 1, e = 2, i = 3, a = 4, t = 5, s = 6, r = 7, c = 8 }
for key, workspace in pairs(workspaceKeys) do
	bind(key, hl.dsp.focus({ workspace = workspace }))
	bind("CONTROL + " .. key, hl.dsp.window.move({ workspace = workspace }))
end
for workspace = 1, 8 do
	bind(tostring(workspace), hl.dsp.focus({ workspace = workspace }))
	bind("CONTROL + " .. tostring(workspace), hl.dsp.window.move({ workspace = workspace }))
end

-- Bind workspaces to specific monitors.
for workspace = 1, 4 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-5", default = workspace == 1 })
end
for workspace = 5, 8 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "HDMI-A-2", default = workspace == 5 })
end

-- Scroll through existing workspaces.
hl.bind("ALT + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Enter keybind-clean mode.
hl.bind("ALT + F9", hl.dsp.submap("clean"))
hl.define_submap("clean", function()
	hl.bind("ALT + F9", hl.dsp.submap("reset"))
end)

-- Laptop multimedia keys for volume and LCD brightness.
local lockedRepeating = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), lockedRepeating)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), lockedRepeating)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), lockedRepeating)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), lockedRepeating)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), lockedRepeating)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), lockedRepeating)

local locked = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)

-- Clipboard history.
bind(
	"H",
	hl.dsp.exec_cmd(
		"cliphist list | awk -F'\\t' '{print $2}' | wofi -d --conf ~/.config/wofi/dmenu.conf | cliphist decode | wl-copy"
	)
)

-- Screenshot.
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-------------------------------
---- WINDOWS AND WORKSPACES ----
-------------------------------

window_rule({
	name = "windowrule-11",
	match = { class = "^(org.gnome.Calculator)$", title = "^(Calculator)$" },
	float = true,
})

window_rule({ name = "windowrule-12", match = { class = ".*" }, suppress_event = "maximize" })

window_rule({
	name = "windowrule-13",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

window_rule({ name = "windowrule-14", match = { class = "^spotify" }, monitor = "HDMI-A-2", workspace = "7" })
window_rule({ name = "windowrule-15", match = { class = "^vesktop" }, monitor = "HDMI-A-2", workspace = "6" })
window_rule({
	name = "windowrule-16",
	match = { class = "^google-chrome$", title = "^Google Chrome$" },
	monitor = "DP-5",
	workspace = "2",
})
window_rule({
	name = "windowrule-17",
	match = { class = "^zen$", title = "^Zen Browser$" },
	monitor = "DP-5",
	workspace = "2",
})
window_rule({ name = "windowrule-18", match = { class = "^steam" }, monitor = "DP-5" })
window_rule({ name = "windowrule-19", match = { class = "^steam$" }, workspace = "3 silent" })
window_rule({ name = "windowrule-20", match = { class = "^wasistlos" }, monitor = "HDMI-A-2", workspace = "8" })
window_rule({ name = "windowrule-21", match = { title = "^WhatsApp Web$" }, monitor = "HDMI-A-2", workspace = "8" })
window_rule({ name = "windowrule-22", match = { class = "^WhatSie$" }, monitor = "HDMI-A-2" })
window_rule({ name = "windowrule-23", match = { title = "^WhatSie$" }, workspace = "8" })

window_rule({ name = "windowrule-25", match = { title = "(Path of Exile)" }, tag = "+poe" })
window_rule({ name = "windowrule-26", match = { class = "(steam_app_238960)" }, tag = "+poe" })
window_rule({ name = "windowrule-27", match = { tag = "poe" }, fullscreen = true })
window_rule({ name = "windowrule-28", match = { title = "(Awakened PoE Trade)" }, tag = "+apt" })
window_rule({
	name = "windowrule-29",
	match = { tag = "apt" },
	float = true,
	no_blur = true,
	no_shadow = true,
	border_size = 0,
	pin = true,
	render_unfocused = true,
	size = "monitor_w*1 monitor_h*1",
	center = true,
})
window_rule({ name = "windowrule-30", match = { tag = "apt" }, no_focus = true })

