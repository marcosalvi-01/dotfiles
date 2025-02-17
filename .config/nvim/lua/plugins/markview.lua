return {
	"OXY2DEV/markview.nvim",
	-- lazy = false,      -- Recommended
	ft = "markdown", -- If you decide to lazy-load anyway

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		preview = {
			modes = { "n", "no", "c" },
		},
		-- hybrid_modes = {  "i" },
	},
}
