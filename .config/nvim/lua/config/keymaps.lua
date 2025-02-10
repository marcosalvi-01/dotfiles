-- Clear search with esc
-- vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfixlist" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show [E]rror" })
vim.keymap.set("n", "ge", vim.diagnostic.goto_next, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "gE", vim.diagnostic.goto_prev, { desc = "[G]o to next [E]rror" })

-- Remap arrows
vim.keymap.set({ "n", "v" }, "<Left>", "h")
vim.keymap.set({ "n", "v" }, "<Right>", "l")
vim.keymap.set({ "n", "v" }, "<Up>", "gk")
vim.keymap.set({ "n", "v" }, "<Down>", "gj")

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving the cursor" })
vim.keymap.set("n", "S", "i<CR><Esc>", { desc = "[S]plit lines" })

vim.keymap.set("n", ",", ";")
vim.keymap.set("n", ";", ",")

vim.keymap.set("n", "<Home>", "_")
vim.keymap.set("n", "<End>", "$")

vim.keymap.set("n", "Q", "`", { remap = true })

-- MOVED TO CINNAMON FOR ANIMATIONS
-- vim.keymap.set("n", "<leader><BS>E", function()
-- 	vim.cmd.cprev()
-- 	vim.cmd.normal("zz")
-- end, { desc = "[G]o to previous [E]ntry in the Quickfix list" })
-- vim.keymap.set("n", "<leader><BS>e", function()
-- 	vim.cmd.cnext()
-- 	vim.cmd.normal("zz")
-- end, { desc = "[G]o to next [E]ntry in the Quickfix list" })

-- vim.keymap.set("n", "<PageUp>", "<C-u>zz")
-- vim.keymap.set("n", "<PageDown>", "<C-d>zz")
-- vim.keymap.set("n", "<PageUp>", function()
-- 	require("cinnamon").scroll("<C-u>zz")
-- end)
-- vim.keymap.set("n", "<PageDown>", function()
-- 	require("cinnamon").scroll("<C-d>zz")
-- end)

-- vim.keymap.set("n", "n", "nzz")
-- vim.keymap.set("n", "N", "Nzz")
-- vim.keymap.set("n", "n", function()
-- 	require("cinnamon").scroll("nzz")
-- end)
-- vim.keymap.set("n", "N", function()
-- 	require("cinnamon").scroll("Nzz")
-- end)

-- vim.keymap.set("n", "<C-o>", "<C-o>zz")
-- vim.keymap.set("n", "<C-i>", "<C-i>zz")
-- vim.keymap.set("n", "<C-o>", function()
-- 	require("cinnamon").scroll("<C-o>zz")
-- end)
-- vim.keymap.set("n", "<C-i>", function()
-- 	require("cinnamon").scroll("<C-i>zz")
-- end)

vim.keymap.set({ "n", "v" }, "H", "~")

vim.keymap.set("n", "vv", "viw")

vim.keymap.set("v", "P", '"_dp')
vim.keymap.set("v", "p", '"_dP')
vim.keymap.set("v", "<leader>p", "p")

-- using ctrl + h because kitty seems to interpret ctrl + backspace as that, don't know w
vim.keymap.set({ "i", "c" }, "<C-H>", "<C-w>", { desc = "Delete word in insert mode" })

vim.keymap.set("n", "ZF", "ZQ", { desc = "Quit without saving" })

vim.keymap.set("n", "<leader>w", function()
	vim.cmd("silent! wa")
	print("All buffer changes written")
end, { desc = "[W]rite all buffer" })

vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "Open file bowser (Oil)" })

vim.keymap.set("n", "<leader>nl", "<cmd>Noice telescope<cr>", { desc = "Open [N]oice [L]ogs" })

vim.keymap.set("n", "<leader>osw", "<cmd>set wrap<cr>", { desc = "([O]ptions) [S]et [W]rap" })

vim.keymap.set("n", "<Enter>", "o<Esc>", { desc = "Add new line under cursor and move to it in normal mode" })
vim.keymap.set("n", "<S-CR>", "m`O<Esc>``", { desc = "Add new line before the current one" })

-- Invert current word
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
	}

	-- Create complete inversions table with both directions
	local inversions = {}
	for word, inverse in pairs(base_pairs) do
		inversions[word] = inverse
		inversions[inverse] = word
	end

	-- Get the word under cursor
	local word = vim.fn.expand("<cword>")

	-- Check if word exists in our inversions table
	if inversions[word:lower()] then
		-- Get the inverted word
		local inverted = inversions[word:lower()]

		-- Preserve the original case
		if word:sub(1, 1):match("%u") then
			inverted = inverted:sub(1, 1):upper() .. inverted:sub(2)
		end

		-- Replace the word under cursor
		vim.cmd("normal! ciw" .. inverted)
	end
end, { desc = "[!]Invert current word" })

vim.keymap.set("n", "<leader>sw", "*")

vim.keymap.set("n", "<leader>v", "gv", { desc = "Reselect last [V]isual selection" })

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
		if client and client.supports_method("textDocument/inlayHint") then
			vim.keymap.set("n", "<leader>ih", function()
				local currently_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
				vim.lsp.inlay_hint.enable(not currently_enabled, { bufnr = bufnr })
				vim.notify("Inlay hints " .. (not currently_enabled and "enabled" or "disabled"))
			end, { buffer = bufnr, desc = "Toggle [I]nlay [H]ints" })
		end
	end,
})
