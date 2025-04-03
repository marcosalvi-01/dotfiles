-- Diagnostic keymaps
local errorShowing = false
local jumping = false

local function hideVirtualLines()
	vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
	errorShowing = false
end

local function showVirtualLines()
	vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
		callback = function()
			-- Only hide virtual lines if not in the middle of a jump
			if not jumping then
				hideVirtualLines()
			end
			return true
		end,
		once = true,
	})
	errorShowing = true
end

vim.keymap.set("n", "<leader>e", function()
	if errorShowing then
		hideVirtualLines()
	else
		showVirtualLines()
	end
end, { desc = "Toggle error display" })

---@param jumpCount number
local function jumpWithVirtLineDiags(jumpCount)
	jumping = true
	vim.diagnostic.jump({ count = jumpCount })
	showVirtualLines()
	-- Clear the jumping flag after a short delay so that subsequent user moves can hide the lines
	vim.defer_fn(function()
		jumping = false
	end, 50)
end

vim.keymap.set("n", "ge", function()
	jumpWithVirtLineDiags(1)
end, { desc = "[G]o to next [E]rror" })

vim.keymap.set("n", "gE", function()
	jumpWithVirtLineDiags(-1)
end, { desc = "[G]o to previous [E]rror" })
