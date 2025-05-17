return {
	"rrethy/vim-illuminate",
	config = function()
		local illuminate = require("illuminate")

		illuminate.configure({
			disable_keymaps = true,
			filetypes_denylist = {
				"dirbuf",
				"dirvish",
				"fugitive",
				"help",
				"oil",
				"NeogitStatus",
				"gitcommit",
				"markdown",
				"text",
			},
			modes_allowlist = {
				"n",
				"v",
			},
		})

		vim.keymap.set({ "n", "v" }, "<c-n>", function()
			illuminate.goto_next_reference()
		end, { desc = "test" })
		vim.keymap.set({ "n", "v" }, "<c-p>", function()
			illuminate.goto_prev_reference()
		end, { desc = "test" })
	end,
}
