return {
	"refractalize/oil-git-status.nvim",
	dependencies = {
		"stevearc/oil.nvim",
	},
	config = true,
	opts = {
		symbols = { -- customize the symbols that appear in the git status columns
			index = {
				["!"] = "",
				["?"] = "?",
				["A"] = "┃",
				["C"] = "┃",
				["D"] = "┃",
				["M"] = "┃",
				["R"] = "┃",
				["T"] = "┃",
				["U"] = "┃",
				[" "] = " ",
			},
			working_tree = {
				["!"] = "",
				["?"] = "?",
				["A"] = "┃",
				["C"] = "┃",
				["D"] = "┃",
				["M"] = "┃",
				["R"] = "┃",
				["T"] = "┃",
				["U"] = "┃",
				[" "] = " ",
			},
		},
		show_ignored = true,
	},
}
