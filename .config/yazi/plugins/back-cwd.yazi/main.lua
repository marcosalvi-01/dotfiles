local state_option = ya.sync(function(state, attr)
	return state[attr]
end)

return {
	setup = function(state, options)
		state.start_dir = options.start_dir
	end,

	entry = function()
		start_dir = state_option("start_dir")
		ya.mgr_emit("cd", { Url(start_dir) })
	end,
}
