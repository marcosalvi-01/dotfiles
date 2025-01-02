local colors = require("colors")
local appIcons = require("app_icons")

-- Global media object to track multiple players and their states
GlobalMedia = {}

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
	-- Update or create a new player entry in the GlobalMedia table
	local playerName = env.INFO.app
	GlobalMedia[playerName] = {
		state = env.INFO.state,
		title = env.INFO.title,
		artist = env.INFO.artist,
	}

	-- Resolve the app key using the mapping table
	local icon = appIcons[playerName] or ""
	if icon == "" then
		media:set({
			drawing = false,
		})
		return
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

media:subscribe("mouse.clicked", function()
	-- Handle the current player (assuming a single focused player for simplicity)
	local currentPlayer = nil
	for player, data in pairs(GlobalMedia) do
		if data.state == "playing" or data.state == "paused" then
			currentPlayer = player
			break
		end
	end

	if not currentPlayer then
		return -- No active player to control
	end

	local currentState = GlobalMedia[currentPlayer].state

	if currentState == "playing" then
		sbar.exec("osascript -e 'tell application \"" .. currentPlayer .. "\" to pause'")
		GlobalMedia[currentPlayer].state = "paused"
	elseif currentState == "paused" then
		sbar.exec("osascript -e 'tell application \"" .. currentPlayer .. "\" to play'")
		GlobalMedia[currentPlayer].state = "playing"
	end
end)

