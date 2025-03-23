return {
	-- dir = "~/neogo",
	"marcosalvi-01/neogo",
	ft = "go",
	opts = {},
	keys = {
		{
			"<leader>he",
			function()
				require("neogo").iferr.insert()
			end,
			{ buffer = true, desc = "[H]andle [E]rror [Neogo]" },
			ft = "go",
		},
		{
			"<leader>gt",
			function()
				require("neogo").gomodifytags.add()
			end,
			{ buffer = true, desc = "[G]o Add Json [T]ags [Neogo]" },
			ft = "go",
		},
		{
			"<leader>gT",
			function()
				require("neogo").gomodifytags.execute({
					popup_input = true, -- prompt for additional configs
				})
			end,
			{ buffer = true, desc = "[G]o Modify [T]ags Execude [Neogo]" },
			ft = "go",
		},
		{
			"<leader>gp",
			function()
				require("neogo").fixplurals.run()
			end,
			{ buffer = true, desc = "[G]o Fix [P]lurals (in current package) [Neogo]" },
			ft = "go",
		},
		{
			"<leader>gi",
			function()
				require("neogo").impl.generate()
			end,
			{ buffer = true, desc = "[G]o [I]mplement Interface [Neogo]" },
			ft = "go",
		},
		{
			"<leader>ge",
			function()
				require("neogo").goenum.generate()
			end,
			{ buffer = true, desc = "[G]o Modify [T]ags Execude [Neogo]" },
			ft = "go",
		},
	},
}
