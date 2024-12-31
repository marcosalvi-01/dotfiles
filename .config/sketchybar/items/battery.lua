local colors = require("colors")

local battery_icon = {
	_100 = "",
	_75 = "",
	_50 = "",
	_25 = "",
	_0 = "",
	charging = "󱐌",
}

local battery = sbar.add("item", {
	position = "center",
	background = {
		color = colors.magenta,
	},
	update_freq = 120,
})

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local found, _, charge = 0, 0, 0

		if string.find(batt_info, "AC Power") then
			icon = battery.charging
		else
			found, _, charge = batt_info:find("(%d+)%%")
			if found then
				charge = tonumber(charge)
			end

			if found and charge > 80 then
				icon = battery_icon._100
			elseif found and charge > 60 then
				icon = battery_icon._75
			elseif found and charge > 40 then
				icon = battery_icon._50
			elseif found and charge > 20 then
				icon = battery_icon._25
			else
				icon = battery_icon._0
			end
		end

		battery:set({ icon = icon, label = charge .. "%" })
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)
