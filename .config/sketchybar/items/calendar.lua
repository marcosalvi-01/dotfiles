local colors = require("colors")

local cal = sbar.add("item", {
	icon = {
		string = "",
		padding_left = 12,
		font = {
			size = 20,
		}
	},
	position = "right",
	update_freq = 15,
	background = {
		color = colors.yellow,
	},
})

local function update()
	local date = os.date("%a %d %b, %Y")
	-- local time = os.date("%H:%M")
	cal:set({ label = date })
end

cal:subscribe("routine", update)
cal:subscribe("forced", update)
