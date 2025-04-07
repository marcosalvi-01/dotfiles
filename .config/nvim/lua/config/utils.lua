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

local char_to_hex = function(c)
	return string.format("%%%02X", string.byte(c))
end

M.urlencode = function(url)
	if url == nil then
		return
	end
	url = url:gsub("\n", "\r\n")
	url = url:gsub("([^%w ])", char_to_hex)
	url = url:gsub(" ", "+")
	return url
end

local hex_to_char = function(x)
	return string.char(tonumber(x, 16))
end

M.urldecode = function(url)
	if url == nil then
		return
	end
	url = url:gsub("+", " ")
	url = url:gsub("%%(%x%x)", hex_to_char)
	return url
end

return M
