local colors = require("colors")

local memory = sbar.add("item", {
	icon = {
		string = "",
		padding_left = 12,
		font = {
			size = 20,
		},
	},
	position = "center",
	update_freq = 5,
	background = {
		color = colors.yellow,
	},
})

local function update()
	sbar.exec(
		"vm_stat | awk 'BEGIN {FS=\"[: ]+\"} /Pages free/ {free=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {speculative=$3} /Pages active/ {active=$3} /Pages wired down/ {wired=$4} END {unused=free+inactive+speculative; used=active+wired; total=unused+used; print int((used/total)*100)}'",
		function(mem_info)
			memory:set({ label = mem_info .. "%" })
		end
	)
end

memory:subscribe("routine", update)
memory:subscribe("forced", update)
