local M = {}

-- Build a gate that checks the first non-space token against snippet-like triggers.
-- Supports:
--   "foo" (exact), "foo*" (prefix),
--   { exact = "foo" }, { prefix = "foo" }, { pattern = "[di]?printf" }
-- Per-filetype via by_filetype = { ft = { ... } }
M.gate_first_word = function(opts)
	opts = opts or {}
	local ignore_case = opts.ignore_case ~= false
	local defaults = opts.triggers or {}
	local by_ft = opts.by_filetype or {}

	local function norm(s)
		return ignore_case and s:lower() or s
	end
	local function match_first(first, trig)
		if type(trig) == "string" then
			local s = norm(trig)
			if s:sub(-1) == "*" then
				local p = s:sub(1, -2)
				return norm(first):sub(1, #p) == p
			else
				return norm(first) == s
			end
		elseif type(trig) == "table" then
			if trig.prefix then
				return norm(first):sub(1, #trig.prefix) == norm(trig.prefix)
			end
			if trig.exact then
				return norm(first) == norm(trig.exact)
			end
			if trig.pattern then
				return (first:match("^" .. trig.pattern) ~= nil)
			end
		end
		return false
	end

	-- Blink may call gates without ctx in some paths; be defensive.
	return function(ctx)
		local bufnr, row
		if ctx and ctx.bufnr and ctx.cursor then
			bufnr = ctx.bufnr
			row = ctx.cursor[1] - 1
		else
			bufnr = vim.api.nvim_get_current_buf()
			row = (vim.api.nvim_win_get_cursor(0) or { 1, 0 })[1] - 1
		end
		if row < 0 then
			row = 0
		end

		local line = (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or "")
		local first = line:match("^%s*(%S*)") or ""
		local ft = (vim.bo[bufnr] and vim.bo[bufnr].filetype) or vim.bo.filetype or ""

		local triggers = {}
		for i = 1, #defaults do
			triggers[#triggers + 1] = defaults[i]
		end
		local extra = by_ft[ft]
		if extra then
			for i = 1, #extra do
				triggers[#triggers + 1] = extra[i]
			end
		end

		for _, t in ipairs(triggers) do
			if match_first(first, t) then
				return true
			end
		end
		return false
	end
end

return M
