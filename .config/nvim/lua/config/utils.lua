local M = {}

M.printTable = function(t)
	local result = {}
	for key, value in pairs(t) do
		local formattedValue
		if type(value) == "table" then
			formattedValue = M.printTable(value)
		elseif type(value) == "string" then
			formattedValue = string.format("%q", value) -- Quote strings
		else
			formattedValue = tostring(value)
		end
		table.insert(result, tostring(key) .. "=" .. formattedValue)
	end
	print("{" .. table.concat(result, ", ") .. "}")
end

return M
