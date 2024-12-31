local colors = require("colors")

local cpu = sbar.add("item", {
	icon = {
		string = "",
		padding_left = 12,
		font = {
			size = 20,
		},
	},
	position = "center",
	update_freq = 5,
	background = {
		color = colors.magenta,
	},
})

local function update()
	sbar.exec("top -l 1 | grep 'CPU usage' | awk '{print int(($3 + $5) + 0.5)}'", function(cpu_info)
		cpu:set({ label = cpu_info .. "%" })
	end)
end

cpu:subscribe("routine", update)
cpu:subscribe("forced", update)
