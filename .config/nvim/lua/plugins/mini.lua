return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		require("mini.ai").setup()

		require("mini.surround").setup()

		-- Move lines in every direction
		require("mini.move").setup({
			mappings = {
				left = "<S-Left>",
				right = "<S-Right>",
				down = "<S-Down>",
				up = "<S-Up>",
			},
		})

		require("mini.hipatterns").setup({
			highlighters = {
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			},
		})

		-- text object for comments gc
		require("mini.comment").setup()

		-- gS for toggling split join args
		require("mini.splitjoin").setup()
	end,
}
