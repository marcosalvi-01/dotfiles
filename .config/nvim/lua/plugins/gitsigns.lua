return {
	"lewis6991/gitsigns.nvim",
	opts = {
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			map("n", "<leader>hn", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
				vim.cmd("normal! zz")
			end, { desc = "Go to next hunk (Gitsigns)" })

			map("n", "<leader>hp", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
				vim.cmd("normal! zz")
			end, { desc = "Go to previous hunk (Gitsigns)" })

			map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage/Undo current hunk (Gitsigns)" })
			map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset current hunk (Gitsigns)" })
			map("v", "<leader>hs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Stage selected hunk (Gitsigns)" })
			map("v", "<leader>hr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Reset selected hunk (Gitsigns)" })
			map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage entire buffer (Gitsigns)" })
			map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset entire buffer (Gitsigns)" })
			map("n", "<leader>hP", gitsigns.preview_hunk_inline, { desc = "Preview current hunk (Gitsigns)" })
			map("n", "<leader>hb", function()
				gitsigns.blame_line({ full = true })
			end, { desc = "Blame current line with full details (Gitsigns)" })
			map(
				"n",
				"<leader>tb",
				gitsigns.toggle_current_line_blame,
				{ desc = "Toggle blame for current line (Gitsigns)" }
			)
			-- map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff current file (Gitsigns)" })
			map("n", "<leader>hD", function()
				gitsigns.diffthis("~")
			end, { desc = "Diff current file against index (Gitsigns)" })

			-- Text object
			map(
				{ "o", "x" },
				"ih",
				":<C-U>Gitsigns select_hunk<CR>",
				{ desc = "Select hunk as text object (Gitsigns)" }
			)
		end,
	},
}
