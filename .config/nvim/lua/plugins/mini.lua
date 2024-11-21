return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
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

		-- ... and there is more!
		--  Check out: https://github.com/echasnovski/mini.nvim
	end,
}
