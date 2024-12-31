local colors = require("colors")
local appIcons = require("app_icons")

local function truncate(str, n)
	if #str <= n then
		return str -- No truncation needed
	end

	-- Truncate the string normally
	local truncated = str:sub(1, n - 3)

	-- Check if the truncated string ends with " - " and remove it if necessary
	if truncated:sub(-3, -1) == " - " then
		return truncated:sub(1, -3)
	end

	return truncated .. "..."
end

local states = {
	playing = "",
	paused = "",
}

local media = sbar.add("item", {
	position = "center",
	updates = true,
	background = {
		color = colors.green,
	},
	icon = {
		font = {
			size = 24,
		},
	},
	drawing = false,
})

media:subscribe("media_change", function(env)
	-- Resolve the app key using the mapping table
	local icon = appIcons[env.INFO.app] or ""
	if icon == "" then
		media:set({
			drawing = false,
		})
	end
	icon = icon .. " " .. (states[env.INFO.state] or "")

	media:set({
		drawing = true,
		label = truncate(env.INFO.title .. " - " .. env.INFO.artist, 20),
		icon = {
			string = icon, -- Assign the icon
		},
	})
end)
