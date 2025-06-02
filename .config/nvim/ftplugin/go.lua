vim.lsp.inlay_hint.enable(true, { bufnr = 0 })

---@diagnostic disable: undefined-global
local bufnr = vim.api.nvim_get_current_buf()

-- get the gopls server from the given buffer, or nil.
---@param bufnr number
---@return vim.lsp.Client
---@diagnostic disable: redefined-local
local get_gopls = function(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, c in ipairs(clients) do
		if c.name == "gopls" then
			return c
		end
	end
	vim.notify("gopls not found", vim.log.levels.WARN)
	---@diagnostic disable: return-type-mismatch
	return nil
end

-- based on https://github.com/ray-x/go.nvim/blob/c6d5ca26377d01c4de1f7bff1cd62c8b43baa6bc/lua/go/gopls.lua#L57
vim.api.nvim_buf_create_user_command(bufnr, "GoModTidy", function()
	local gopls = get_gopls(bufnr)
	if gopls == nil then
		return
	end

	vim.cmd([[ noautocmd wall ]])
	vim.notify("go mod tidy: running...")

	local uri = vim.uri_from_bufnr(bufnr)
	local arguments = { { URIs = { uri } } }

	local err = gopls:request_sync("workspace/executeCommand", {
		command = "gopls.tidy",
		arguments = arguments,
	}, 30000, bufnr)

	if err ~= nil and type(err[1]) == "table" then
		vim.notify("go mod tidy: " .. vim.inspect(err), vim.log.levels.ERROR)
		return
	end

	vim.notify("go mod tidy: done!")
end, { desc = "go mod tidy" })

vim.keymap.set("n", "<leader>gmt", vim.cmd.GoModTidy, { desc = "go mod tidy & gopls restart" })
