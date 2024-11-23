local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Set font
config.font = wezterm.font_with_fallback({
	"JetBrainsMonoNL Nerd Font Mono",
	-- https://github.com/rbong/flog-symbols to display git branches
	"Flog Symbols",
})
config.font_size = 21

config.enable_kitty_graphics = true
config.enable_kitty_keyboard = true

config.default_domain = "WSL:Ubuntu"

-- Disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Window padding because the font doesn't fit the screen perfectly
config.window_padding = {
	left = "10px",
	right = "0px",
	top = "15px",
	bottom = "0px",
}

-- Disable audible bell
config.audible_bell = "Disabled"

-- Hide the tab bar
config.enable_tab_bar = false

-- Hide window decorations
config.window_decorations = "NONE"

-- Set background image
config.background = {
	{
		source = {
			-- File = wezterm.home_dir .. "/.config/images/mars_minimalist.png",
			File = wezterm.home_dir .. "/.config/images/mars_minimalist_no_shadow.png",
			-- File = wezterm.home_dir .. "/.config/images/mars_minimalist_raw.png",
		},
		width = "Cover",
		height = "Cover",
		horizontal_align = "Center",
		vertical_align = "Middle",
		opacity = 1.0,
		hsb = {
			brightness = 1.0,
			hue = 1.0,
			saturation = 1.0,
		},
	},
	{
		-- Background tin
		source = {
			Color = "rgba(29, 29, 30, 0.6)",
		},
		height = "100%",
		width = "100%",
	},
}

-- Start weztern full screen
local mux = wezterm.mux
wezterm.on("gui-startup", function(window)
	local tab, pane, window = mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
end)

-- Disable all the standard key bindings (they are weird)
config.disable_default_key_bindings = true
-- Set font zoom keys
config.keys = {
	{
		key = "+",
		mods = "CMD",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		-- for some reason wezterm identifies - as = (at least on mac)
		key = "=",
		mods = "CMD",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

config.max_fps = 144
config.animation_fps = 60

-- Custom gruvbox material theme
config.color_schemes = {
	["CustomTheme"] = {
		foreground = "#d4be98",
		background = "#1d1d1d",
		cursor_bg = "#a89984",
		cursor_fg = "#1d1d1d", -- Cursor text color
		selection_bg = "#d4be98",
		selection_fg = "#1d1d1d",
		ansi = {
			"#665c54", -- color0
			"#ea6962", -- color1
			"#689d6a", -- color2
			"#b68242", -- color3
			"#83a598", -- color4
			"#d3869b", -- color5
			"#89b482", -- color6
			"#d4be98", -- color7
		},
		brights = {
			"#928374", -- color8
			"#ea6962", -- color9
			"#689d6a", -- color10
			"#d8a657", -- color11
			"#83a598", -- color12
			"#d3869b", -- color13
			"#89b482", -- color14
			"#d4be98", -- color15
		},
	},
}
config.color_scheme = "CustomTheme"

return config
