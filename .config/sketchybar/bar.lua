local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	height = 40,
	color = colors.bar.bg,
	shadow = false,
	sticky = true,
	padding_right = 10,
	padding_left = 10,
	topmost = "window",
	notch_width = "300",
	display = "main",
})
