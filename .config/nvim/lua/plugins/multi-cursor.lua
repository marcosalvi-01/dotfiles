return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()

		-- Customize how cursors look.
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { link = "Cursor" })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
	end,
	keys = {
		-- Add or skip cursor above/below the main cursor
		{
			"<M-up>",
			function()
				require("multicursor-nvim").lineAddCursor(-1)
			end,
			mode = { "n", "v" },
			desc = "Add a new cursor one line above the current cursor [multicursor]",
		},

		{
			"<M-down>",
			function()
				require("multicursor-nvim").lineAddCursor(1)
			end,
			mode = { "n", "v" },
			desc = "Add a new cursor one line below the current cursor [multicursor]",
		},

		{
			"<leader><M-up>",
			function()
				require("multicursor-nvim").lineSkipCursor(-1)
			end,
			mode = { "n", "v" },
			desc = "Skip adding a cursor and move the selection up one line [multicursor]",
		},

		{
			"<leader><M-down>",
			function()
				require("multicursor-nvim").lineSkipCursor(1)
			end,
			mode = { "n", "v" },
			desc = "Skip adding a cursor and move the selection down one line [multicursor]",
		},

		-- Add all matches in the document
		{
			"<leader>A",
			function()
				require("multicursor-nvim").matchAllAddCursors()
			end,
			mode = { "n", "v" },
			desc = "Add cursors at all matching locations in the document [multicursor]",
		},

		-- Add cursors with motions
		{
			"<M-right>",
			function()
				require("multicursor-nvim").addCursor("w")
			end,
			mode = "n",
			desc = "Add a cursor at the next word [multicursor]",
		},

		{
			"<M-left>",
			function()
				require("multicursor-nvim").addCursor("b")
			end,
			mode = "n",
			desc = "Add a cursor at the previous word [multicursor]",
		},

		{
			"<leader><M-right>",
			function()
				require("multicursor-nvim").skipCursor("w")
			end,
			mode = "n",
			desc = "Skip adding a cursor and move to the next word [multicursor]",
		},

		{
			"<leader><M-left>",
			function()
				require("multicursor-nvim").skipCursor("b")
			end,
			mode = "n",
			desc = "Skip adding a cursor and move to the previous word [multicursor]",
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

		-- Append/insert for each line of visual selections
		{
			"I",
			function()
				require("multicursor-nvim").insertVisual()
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

		-- Jumplist support
		{
			"<c-i>",
			function()
				require("multicursor-nvim").jumpForward()
			end,
			mode = { "v", "n" },
			desc = "Jump forward in cursor history [multicursor]",
		},

		{
			"<c-o>",
			function()
				require("multicursor-nvim").jumpBackward()
			end,
			mode = { "v", "n" },
			desc = "Jump backward in cursor history [multicursor]",
		},
	},
}
