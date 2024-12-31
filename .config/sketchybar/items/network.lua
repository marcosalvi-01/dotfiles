local colors = require("colors")

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "center",
	label = { drawing = false },
	icon = {
		drawing = true,
		padding_right = 8,
	},
	background = {
		color = colors.yellow,
	},
	-- click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 'Control Center,WiFi'",
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
}, {
	popup = {
		drawing = false,
		align = "center",
		background = {
			color = colors.black,
			border_color = colors.green,
		},
	},
})

local ssid = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		padding_right = 16,
		string = "󰑩 -",
		font = {
			size = 24,
		},
		color = colors.white,
	},
	label = {
		max_chars = 25,
		string = "????????????",
		color = colors.white,
	},
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		padding_right = 16,
		string = "󰌢 -",
		font = {
			size = 24,
		},
		color = colors.white,
	},
	label = {
		max_chars = 20,
		string = "????????????",
		color = colors.white,
	},
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		padding_right = 16,
		string = "󱦂 -",
		font = {
			size = 24,
		},
		color = colors.white,
	},
	label = {
		string = "???.???.???.???",
		color = colors.white,
	},
})

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
	sbar.exec("ipconfig getifaddr en0", function(ip)
		local connected = not (ip == "")
		wifi:set({
			icon = {
				string = connected and "󰤨" or "󰤭",
			},
			background = {
				color = connected and colors.green or colors.red,
			},
		})
		wifi_bracket:set({
			popup = {
				background = {
					border_color = connected and colors.green or colors.red,
				},
			},
		})
	end)
end)

local function toggle_details()
	local current_drawing = wifi_bracket:query().popup.drawing
	local should_draw = current_drawing == "off"

	-- Toggle popup visibility
	wifi_bracket:set({ popup = { drawing = should_draw } })

	-- If opening the popup, refresh the details
	if should_draw then
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = result })
		end)
		sbar.exec("ipconfig getifaddr en0", function(result)
			ip:set({ label = result })
		end)
		sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
			ssid:set({ label = result })
		end)
	end
end

local function hide_details()
	wifi_bracket:set({ popup = { drawing = false } })
end

wifi:subscribe("mouse.entered", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)
wifi:subscribe("mouse.exited", hide_details)

local function copy_label_to_clipboard(env)
	local label = sbar.query(env.NAME).label.value
	sbar.exec('echo "' .. label .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = " - Copied!", align = "center" } })
	sbar.delay(2, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
