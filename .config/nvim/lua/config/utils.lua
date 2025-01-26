local M = {}

M.printTable = function(t, indent)
	-- Use `indent` to format nested levels
	indent = indent or 0
	local indentStr = string.rep("  ", indent) -- Add 2 spaces per level of nesting

	for key, value in pairs(t) do
		if type(value) == "table" then
			-- If the value is a table, print its key and recursively print its content
			print(indentStr .. tostring(key) .. ": {")
			M.printTable(value, indent + 1)
			print(indentStr .. "}")
		else
			-- Otherwise, print the key and value
			print(indentStr .. tostring(key) .. ": " .. tostring(value))
		end
	end
end

return M
