return {
	"declancm/cinnamon.nvim",
	config = function()
		require("cinnamon").setup({
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

		vim.keymap.set("n", "n", function()
			require("cinnamon").scroll("nzz")
		end)
		vim.keymap.set("n", "N", function()
			require("cinnamon").scroll("Nzz")
		end)

		vim.keymap.set("n", "<C-o>", function()
			require("cinnamon").scroll("<C-o>zz")
		end)
		vim.keymap.set("n", "<C-i>", function()
			require("cinnamon").scroll("<C-i>zz")
		end)

		vim.keymap.set("n", "<leader><BS>E", function()
			require("cinnamon").scroll(function()
				vim.cmd.cprev()
				vim.cmd.normal("zz")
			end)
		end, { desc = "[G]o to previous [E]ntry in the Quickfix list" })
		vim.keymap.set("n", "<leader><BS>e", function()
			require("cinnamon").scroll(function()
				vim.cmd.cnext()
				vim.cmd.normal("zz")
			end)
		end, { desc = "[G]o to next [E]ntry in the Quickfix list" })

		-- Disable scrolling for help buffers
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.b.cinnamon_disable = true
			end,
		})
	end,
}
