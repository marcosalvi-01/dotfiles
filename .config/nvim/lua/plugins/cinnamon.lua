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

		-- Quickfix navigation (with cycles)
		vim.keymap.set("n", "<leader><left>", function()
			require("cinnamon").scroll(function()
				vim.cmd("try | cprevious | catch | clast | catch")
				vim.cmd.normal("zz")
			end)
		end, { desc = "[G]o to previous [E]ntry in the Quickfix list" })
		vim.keymap.set("n", "<leader><right>", function()
			require("cinnamon").scroll(function()
				vim.cmd("try | cnext | catch | cfirst | catch")
				vim.cmd.normal("zz")
			end)
		end, { desc = "[G]o to next [E]ntry in the Quickfix list" })

		-- Disable scrolling for oil
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.b.cinnamon_disable = true
			end,
		})
	end,
}
