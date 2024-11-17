return {
	"nvim-neorg/neorg",
	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	version = "9.1.1", -- Pin Neorg to the latest stable release
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				-- Pretty icons
				["core.concealer"] = {},
				-- ["core.completion"] = {
				-- 	engine = "nvim-cmp"
				-- },
				-- Workspaces management
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/notes",
						},
						index = "index.norg",
					},
					default_workspace = "notes",
				},
			},
		})
	end,
}
