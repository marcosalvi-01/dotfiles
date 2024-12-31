local settings = require("settings")
local colors = require("colors")

local popup = {
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font,
			style = "Bold",
			size = 30.0,
		},
		color = colors.black,
		padding_left = 8,
		padding_right = 5,
	},
	label = {
		font = {
			family = settings.font,
			style = "semibold",
			size = 19.0,
		},
		color = colors.black,
		padding_left = 5,
		padding_right = 11,
	},
	background = {
		height = 26,
		corner_radius = 13,
		border_width = 2,
	},
	popup = {
		background = {
			border_width = 2,
			corner_radius = 9,
			border_color = colors.popup.border,
			color = colors.popup.bg,
			shadow = { drawing = true },
		},
		blur_radius = 20,
	},
	padding_left = 5,
	padding_right = 5,
}

return popup
