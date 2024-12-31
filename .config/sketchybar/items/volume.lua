local colors = require("colors")
local volume = {
	_100 = "",
	_66 = "",
	_33 = "",
	_10 = "",
	_0 = "",
}

-- local volume_slider = sbar.add("slider", 100, {
-- 	position = "right",
-- 	updates = true,
-- 	label = {
-- 		padding_right = 12,
-- 		padding_left = 4,
-- 		string = volume._100,
-- 		font = {
-- 			size = 30,
-- 		},
-- 	},
-- 	icon = {
-- 		padding_left = 8,
-- 		padding_right = 10,
-- 		string = volume._0,
-- 		font = {
-- 			size = 30,
-- 		},
-- 	},
-- 	background = {
-- 		color = colors.blue,
-- 	},
-- 	slider = {
-- 		highlight_color = colors.black,
-- 		background = {
-- 			height = 6,
-- 			corner_radius = 3,
-- 			color = colors.blue,
-- 		},
-- 		-- knob = {
-- 		-- 	string = "",
-- 		-- 	drawing = true,
-- 		-- 	font = "JetBrainsMono Nerd Font Mono"
-- 		-- },
-- 	},
-- })

local volume_icon = sbar.add("item", {
	position = "center",
	icon = {
		string = volume._100,
	},
	background = {
		color = colors.blue,
	},
})

-- volume_slider:subscribe("mouse.clicked", function(env)
-- 	sbar.exec("osascript -e 'set volume output volume " .. env["PERCENTAGE"] .. "'")
-- end)
--
volume_icon:subscribe("volume_change", function(env)
	local vol = tonumber(env.INFO)
	local icon = volume._0
	if vol > 60 then
		icon = volume._100
	elseif vol > 30 then
		icon = volume._66
	elseif vol > 10 then
		icon = volume._33
	elseif vol > 0 then
		icon = volume._10
	end

	volume_icon:set({ label = vol .. "%", icon = icon })
	-- volume_slider:set({ slider = { percentage = vol } })
end)
--
-- local function animate_slider_width(width)
-- 	sbar.animate("tanh", 30.0, function()
-- 		volume_slider:set({ slider = { width = width } })
-- 	end)
-- end
--
-- volume_icon:subscribe("mouse.clicked", function()
-- 	if tonumber(volume_slider:query().slider.width) > 0 then
-- 		animate_slider_width(0)
-- 	else
-- 		animate_slider_width(100)
-- 	end
-- end)
