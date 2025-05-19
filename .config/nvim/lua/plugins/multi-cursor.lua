return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	opts = {},
	keys = {
		-- Add all matches in the document
		{
			"<leader>/",
			function()
				require("multicursor-nvim").matchAllAddCursors()
			end,
			mode = { "n", "v" },
			desc = "Add cursors at all matching locations in the document [multicursor]",
		},

		-- Easy way to add and remove cursors using the main cursor
		{
			"<c-q>",
			function()
				require("multicursor-nvim").toggleCursor()
			end,
			mode = { "n", "v" },
			desc = "Toggle cursor at current position and enable all cursors [multicursor]",
		},

		-- ESC key handling
		{
			"<esc>",
			function()
				local mc = require("multicursor-nvim")
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				elseif mc.hasCursors() then
					mc.clearCursors()
				else
					-- Default <esc> handler
					vim.cmd("nohlsearch")
				end
			end,
			mode = "n",
			desc = "Toggle cursor mode or clear search highlighting [multicursor]",
		},

		-- Bring back cursors if you accidentally clear them
		{
			"<leader>gv",
			function()
				require("multicursor-nvim").restoreCursors()
			end,
			mode = "n",
			desc = "Restore previously cleared cursors [multicursor]",
		},

		-- insert for each line of visual selections
		{
			"I",
			function()
				require("multicursor-nvim").addCursorOperator()
			end,
			mode = "v",
			desc = "Insert text at the start of each line in visual selection [multicursor]",
		},

		{
			"A",
			function()
				require("multicursor-nvim").appendVisual()
			end,
			mode = "v",
			desc = "Append text at the end of each line in visual selection [multicursor]",
		},

		-- Rotate visual selection contents
		{
			"<leader>t",
			function()
				require("multicursor-nvim").transposeCursors(1)
			end,
			mode = "v",
			desc = "Rotate visual selection contents forward [multicursor]",
		},

		{
			"<leader>T",
			function()
				require("multicursor-nvim").transposeCursors(-1)
			end,
			mode = "v",
			desc = "Rotate visual selection contents backward [multicursor]",
		},
	},
}
