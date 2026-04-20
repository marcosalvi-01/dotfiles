return {
	"declancm/cinnamon.nvim",
	config = function()
		require("cinnamon").setup({
			options = {
				max_delta = {
					time = 1000,
				},
			},
			keymaps = {
				basic = true,
				extra = false,
			},
		})

		vim.keymap.set("n", "<PageUp>", function()
			require("cinnamon").scroll("<C-u>zz")
		end)
		vim.keymap.set("n", "<PageDown>", function()
			require("cinnamon").scroll("<C-d>zz")
		end)

		-- Disable scrolling for oil
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.b.cinnamon_disable = true
			end,
		})
	end,
}
