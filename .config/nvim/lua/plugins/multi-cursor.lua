return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	opts = {},
	keys = {
		-- Add all matches in the document
		{
			"<leader>A",
			function()
				require("multicursor-nvim").matchAllAddCursors()
			end,
			mode = { "n", "v" },
			desc = "Add cursors at all matching locations in the document [multicursor]",
		},

		-- Delete the main cursor
		{
			"<leader>x",
			function()
				require("multicursor-nvim").deleteCursor()
			end,
			mode = { "n", "v" },
			desc = "Delete the current cursor [multicursor]",
		},

		-- Add and remove cursors with control + left click
		{
			"<c-leftmouse>",
			function()
				require("multicursor-nvim").handleMouse()
			end,
			mode = "n",
			desc = "Toggle cursor at mouse click position [multicursor]",
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

		-- Clone every cursor and disable the originals
		{
			"<leader><c-q>",
			function()
				require("multicursor-nvim").duplicateCursors()
			end,
			mode = { "n", "v" },
			desc = "Clone all cursors and disable the originals [multicursor]",
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

		-- Align cursor columns
		{
			"<leader>a",
			function()
				require("multicursor-nvim").alignCursors()
			end,
			mode = "n",
			desc = "Align all cursors to the same column [multicursor]",
		},

		-- Split visual selections by regex
		{
			"S",
			function()
				require("multicursor-nvim").splitCursors()
			end,
			mode = "v",
			desc = "Split visual selection into multiple cursors using regex [multicursor]",
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

		-- Match new cursors within visual selections by regex
		{
			"M",
			function()
				require("multicursor-nvim").matchCursors()
			end,
			mode = "v",
			desc = "Add cursors at regex matches within visual selection [multicursor]",
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
