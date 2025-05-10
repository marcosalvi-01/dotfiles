-- Remap arrows
vim.keymap.set({ "n", "v" }, "<Left>", "h")
vim.keymap.set({ "n", "v" }, "<Right>", "l")
-- up and down using gX for when line wrapped and also add jump tag when using a count
vim.keymap.set({ "n", "v" }, "<down>", function()
	if vim.v.count > 0 then
		return "m'" .. vim.v.count .. "gj"
	end
	return "gj"
end, { expr = true })
vim.keymap.set({ "n", "v" }, "<Up>", function()
	if vim.v.count > 0 then
		return "m'" .. vim.v.count .. "gk"
	end
	return "gk"
end, { expr = true })

vim.keymap.set("n", "J", "mzJ`z:delmarks z<cr>", { desc = "Join lines without moving the cursor" })
vim.keymap.set("n", "S", "i<CR><Esc>", { desc = "[S]plit lines" })

vim.keymap.set("n", ",", ";")
vim.keymap.set("n", ";", ",")

-- reset the horizontal scroll when doing Home
vim.keymap.set("n", "<Home>", function()
	local current_col = vim.fn.wincol()
	if current_col > 1 then
		vim.cmd("normal! 0")
	end
	vim.cmd("normal! _")
end)
vim.keymap.set("n", "<End>", "$")

vim.keymap.set("n", "Q", "`", { remap = true })

vim.keymap.set({ "n", "v" }, "H", "~")

vim.keymap.set("n", "vv", "viw")

vim.keymap.set("v", "P", '"_dp')
vim.keymap.set("v", "p", '"_dP')
vim.keymap.set("v", "<leader>p", "p")

vim.keymap.set("n", "ZF", "ZQ", { desc = "Quit without saving" })

vim.keymap.set("n", "<bs>", function()
	vim.cmd("silent! wa")
	vim.notify("All buffer changes written")
end, { desc = "[W]rite all buffer" })

vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "Open file bowser (Oil)" })

vim.keymap.set("n", "<leader>l", "<cmd>Noice pick<cr>", { desc = "[S]earch Noice [L]ogs" })

vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "[T]oggle [W]rap" })

vim.keymap.set("n", "<Enter>", 'o<Esc>"_cc<Esc>', { desc = "Add new line under cursor and move to it in normal mode" })
vim.keymap.set("n", "<S-CR>", 'm`O<Esc>"_cc<Esc>``', { desc = "Add new line before the current one" })

-- Invert current word or operator
vim.keymap.set("n", "!", function()
	-- Define base pairs
	local base_pairs = {
		["true"] = "false",
		["True"] = "False",
		["yes"] = "no",
		["on"] = "off",
		["enable"] = "disable",
		["enabled"] = "disabled",
		["vero"] = "falso",
		["&&"] = "||",
		["and"] = "or",
		["!="] = "==",
	}
	-- Create complete inversions table with both directions
	local inversions = {}
	for word, inverse in pairs(base_pairs) do
		inversions[word] = inverse
		inversions[inverse] = word
	end

	-- Yank the current word (this also works for operators)
	vim.cmd('normal! "iyiw')

	-- Get the yanked text
	local word = vim.fn.getreg("i")

	-- Check if word exists in our inversions table
	if inversions[word] then
		-- Replace the word under cursor with its inversion
		vim.cmd('normal! "_ciw' .. inversions[word])
	elseif inversions[word:lower()] then
		-- Get the inverted word
		local inverted = inversions[word:lower()]
		-- Preserve the original case
		if word:sub(1, 1):match("%u") then
			inverted = inverted:sub(1, 1):upper() .. inverted:sub(2)
		end
		-- Replace the word under cursor
		vim.cmd('normal! "_ciw' .. inverted)
	end
end, { desc = "[!]Invert current word or operator" })

vim.keymap.set({ "n", "v" }, "M", function()
	local marks = {}
	for i = string.byte("a"), string.byte("z") do
		local mark = string.char(i)
		-- Get position of the mark
		local pos = vim.api.nvim_buf_get_mark(0, mark)
		-- Check if mark is on current line
		if pos[1] == vim.fn.line(".") then
			table.insert(marks, mark)
		end
	end

	-- If we found any marks, delete them
	if #marks > 0 then
		vim.cmd("delmarks " .. table.concat(marks))
	end
end)

vim.keymap.set("v", "<leader>sed", function()
	-- get the selected text
	local lines = table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() }))
	-- exit visual mode
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", true)
	-- open the %s command
	return vim.fn.feedkeys(":%s/" .. vim.fn.escape(lines, "/\\") .. "/", "n")
end, { desc = "Search and replace selection" })

-- toggle inlay hints
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local bufnr = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		-- Check that the LSP client supports inlay hints
		if client and client.server_capabilities.inlayHintProvider then
			vim.keymap.set("n", "<leader>ih", function()
				local currently_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
				vim.lsp.inlay_hint.enable(not currently_enabled, { bufnr = bufnr })
				vim.notify("Inlay hints " .. (not currently_enabled and "enabled" or "disabled"))
			end, { buffer = bufnr, desc = "Toggle [I]nlay [H]ints" })
		end
	end,
})

vim.keymap.set("x", "/", "<Esc>/\\%V", { desc = "Search inside current visual selection" })

-- SMART DELETE
local function smart_delete(key)
	local l = vim.api.nvim_win_get_cursor(0)[1] -- Get the current cursor line number
	local line = vim.api.nvim_buf_get_lines(0, l - 1, l, true)[1] -- Get the content of the current line
	return (line:match("^%s*$") and '"_' or "") .. key -- If the line is empty or contains only whitespace, use the black hole register
end
local keys = { "d", "x", "c", "s", "C", "X" } -- Define a list of keys to apply the smart delete functionality
-- Set keymaps for both normal and visual modes
for _, key in pairs(keys) do
	vim.keymap.set("n", key, function()
		return smart_delete(key)
	end, { noremap = true, expr = true, desc = "Smart delete" })
end
vim.keymap.set("n", "dd", function()
	return smart_delete("dd")
end, { noremap = true, expr = true, desc = "Smart delete" })

-- Set a keymap in normal mode to run the make command
-- vim.keymap.set("n", "<leader>m", function()
-- 	RunMakeAsync()
-- end, { noremap = true, silent = true, desc = "Run [M]ake in the current working directory" })
--
-- -- Run the 'make' command asynchronously in the current working directory
-- function RunMakeAsync()
-- 	vim.notify("Running make...", vim.log.levels.INFO)
--
-- 	vim.system({ "make" }, {}, function(out)
-- 		if out.code == 0 then
-- 			vim.notify("Make finished successfully", vim.log.levels.INFO)
-- 		else
-- 			vim.notify("Make finished with errors (exit code " .. out.code .. ")", vim.log.levels.ERROR)
-- 		end
-- 	end)
-- end

-- Create a keymap (here using <leader>g in normal mode) to trigger the prompt
vim.keymap.set("n", "<leader>G", function()
	vim.ui.input({ prompt = "Just Google it: " }, function(input)
		if input and input ~= "" then
			vim.cmd("Google " .. input)
		end
	end)
end, { noremap = true, silent = true, desc = "Just Google it" })

-- Keymap to yank all diagnostic messages from current line to clipboard
vim.keymap.set("n", "<leader>ye", function()
	-- Get current line number
	local current_line = vim.fn.line(".")

	-- Get all diagnostic messages for the current line
	local diagnostics = vim.diagnostic.get(0, { lnum = current_line - 1 }) -- 0-indexed in the API

	-- Extract all diagnostic messages
	local messages = {}
	for _, diag in ipairs(diagnostics) do
		table.insert(messages, diag.message)
	end

	-- Join diagnostic messages with newlines
	local diagnostic_text = table.concat(messages, "\n")

	-- If there are diagnostics, copy them to the clipboard
	if #messages > 0 then
		vim.fn.setreg("+", diagnostic_text)
		print("Yanked " .. #messages .. " diagnostic message(s) to clipboard")
	else
		print("No diagnostics found on current line")
	end
end, { desc = "Yank all diagnostics from current line to clipboard" })

-- insert p instead of paste while in substitute mode
vim.keymap.set("s", "p", "p")

-- <C-r> in insert mode to jump to end of current treesitter node
vim.keymap.set("i", "<C-r>", function()
	local node = vim.treesitter.get_node()
	if node ~= nil then
		local row, col = node:end_()
		pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
	end
end, { desc = "Jump to end of current treesitter node" })

-- All the ways to start a search, with a description
local mark_search_keys = {
	["/"] = "Search forward",
	["?"] = "Search backward",
	["*"] = "Search current word (forward)",
	["#"] = "Search current word (backward)",
	["£"] = "Search current word (backward)",
	["g*"] = "Search current word (forward, not whole word)",
	["g#"] = "Search current word (backward, not whole word)",
	["g£"] = "Search current word (backward, not whole word)",
}

-- Before starting the search, set a mark `s`
for key, desc in pairs(mark_search_keys) do
	vim.keymap.set("n", key, "ms" .. key, { desc = desc })
end

-- Clear search highlight when jumping back to beginning
vim.keymap.set("n", "'s", function()
	vim.cmd("normal! `s")
	vim.cmd.nohlsearch()
end)

-- comment and duplicate current line (works with count)
vim.keymap.set("n", "ycc", function()
	return "yy" .. vim.v.count1 .. "gcc']p"
end, { remap = true, expr = true })

-- vim.keymap.set("n", "<leader>cn", vim.lsp.buf.rename, { desc = "Rename symbol" })
-- vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
-- vim.keymap.set("n", "<leader>D", vim.lsp.buf.declaration, { desc = "Go to declaration" })
