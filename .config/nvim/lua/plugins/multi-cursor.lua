return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()
		local set = vim.keymap.set
		-- Add or skip cursor above/below the main cursor.
		-- set({ "n", "v" }, "<M-up>", function()
		-- 	mc.lineAddCursor(-1)
		-- end, { desc = "Add a new cursor one line above the current cursor [multicursor]" })
		-- set({ "n", "v" }, "<M-down>", function()
		-- 	mc.lineAddCursor(1)
		-- end, { desc = "Add a new cursor one line below the current cursor [multicursor]" })
		-- set({ "n", "v" }, "<leader><M-up>", function()
		-- 	mc.lineSkipCursor(-1)
		-- end, { desc = "Skip adding a cursor and move the selection up one line [multicursor]" })
		-- set({ "n", "v" }, "<leader><M-down>", function()
		-- 	mc.lineSkipCursor(1)
		-- end, { desc = "Skip adding a cursor and move the selection down one line [multicursor]" })
		-- Add all matches in the document
		set(
			{ "n", "v" },
			"<leader>A",
			mc.matchAllAddCursors,
			{ desc = "Add cursors at all matching locations in the document [multicursor]" }
		)
		-- You can also add cursors with any motion you prefer:
		set("n", "<M-right>", function()
			mc.addCursor("w")
		end, { desc = "Add a cursor at the next word [multicursor]" })
		set("n", "<M-left>", function()
			mc.addCursor("b")
		end, { desc = "Add a cursor at the previous word [multicursor]" })
		set("n", "<leader><M-right>", function()
			mc.skipCursor("w")
		end, { desc = "Skip adding a cursor and move to the next word [multicursor]" })
		set("n", "<leader><M-left>", function()
			mc.skipCursor("b")
		end, { desc = "Skip adding a cursor and move to the previous word [multicursor]" })
		-- Delete the main cursor.
		set({ "n", "v" }, "<leader>x", mc.deleteCursor, { desc = "Delete the current cursor [multicursor]" })
		-- Add and remove cursors with control + left click.
		set("n", "<c-leftmouse>", mc.handleMouse, { desc = "Toggle cursor at mouse click position [multicursor]" })
		-- Easy way to add and remove cursors using the main cursor.
		set({ "n", "v" }, "<c-q>", function()
			mc.toggleCursor()
			mc.enableCursors()
		end, { desc = "Toggle cursor at current position and enable all cursors [multicursor]" })
		-- Clone every cursor and disable the originals.
		set(
			{ "n", "v" },
			"<leader><c-q>",
			mc.duplicateCursors,
			{ desc = "Clone all cursors and disable the originals [multicursor]" }
		)
		set("n", "<esc>", function()
			if not mc.cursorsEnabled() then
				mc.enableCursors()
			elseif mc.hasCursors() then
				mc.clearCursors()
			else
				-- Default <esc> handler.
				vim.cmd("nohlsearch")
			end
		end, { desc = "Toggle cursor mode or clear search highlighting [multicursor]" })
		-- bring back cursors if you accidentally clear them
		set("n", "<leader>gv", mc.restoreCursors, { desc = "Restore previously cleared cursors [multicursor]" })
		-- Align cursor columns.
		set("n", "<leader>a", mc.alignCursors, { desc = "Align all cursors to the same column [multicursor]" })
		-- Split visual selections by regex.
		set(
			"v",
			"S",
			mc.splitCursors,
			{ desc = "Split visual selection into multiple cursors using regex [multicursor]" }
		)
		-- Append/insert for each line of visual selections.
		set(
			"v",
			"I",
			mc.insertVisual,
			{ desc = "Insert text at the start of each line in visual selection [multicursor]" }
		)
		set(
			"v",
			"A",
			mc.appendVisual,
			{ desc = "Append text at the end of each line in visual selection [multicursor]" }
		)
		-- match new cursors within visual selections by regex.
		set("v", "M", mc.matchCursors, { desc = "Add cursors at regex matches within visual selection [multicursor]" })
		-- Rotate visual selection contents.
		set("v", "<leader>t", function()
			mc.transposeCursors(1)
		end, { desc = "Rotate visual selection contents forward [multicursor]" })
		set("v", "<leader>T", function()
			mc.transposeCursors(-1)
		end, { desc = "Rotate visual selection contents backward [multicursor]" })
		-- Jumplist support
		set({ "v", "n" }, "<c-i>", mc.jumpForward, { desc = "Jump forward in cursor history [multicursor]" })
		set({ "v", "n" }, "<c-o>", mc.jumpBackward, { desc = "Jump backward in cursor history [multicursor]" })
		-- Customize how cursors look.
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { link = "Cursor" })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
	end,
}
