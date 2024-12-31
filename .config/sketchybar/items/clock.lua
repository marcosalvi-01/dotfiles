local colors = require("colors")

local clock = sbar.add("item", {
	icon = {
		string = "󰥔",
		padding_left = 12,
		font = {
			size = 20,
		}
	},
	position = "right",
	update_freq = 1,
	background = {
		color = colors.blue,
	},
})

local function update()
	local time = os.date("%H:%M:%S")
	clock:set({ label = time })
end

clock:subscribe("routine", update)
clock:subscribe("forced", update)
