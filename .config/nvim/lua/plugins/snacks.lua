return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		animate = {
			fps = 100,
		},
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
		},
		quickfile = { enabled = true },
		-- scroll = {
		-- 	animate = {
		-- 		duration = { step = 15, total = 250 },
		-- 		easing = "linear",
		-- 	},
		-- 	animate_repeat = {
		-- 		delay = 100, -- delay in ms before using the repeat animation
		-- 		duration = { step = 5, total = 50 },
		-- 		easing = "linear",
		-- 	},
		-- 	enabled = true,
		-- },
		statuscolumn = {
			left = { "git", "mark" },
			right = { "fold" },
			folds = {
				open = false,
				git_hl = true, -- use Git Signs hl for fold icons
			},
			git = {
				-- patterns to match Git signs
				patterns = { "GitSign", "MiniDiffSign" },
			},
			refresh = 50, -- refresh at most every 50ms
			enabled = true,
		},
		scope = {
			enabled = true,
		},
		-- bigfile = { enabled = true },
		-- dashboard = { enabled = true },
		-- input = { enabled = true },
		-- picker = { enabled = true },
		-- words = { enabled = true },
	},
}
