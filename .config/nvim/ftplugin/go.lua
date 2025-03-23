-- Require the Treesitter utility functions.
local ts_utils = require("nvim-treesitter.ts_utils")

local function add_json_tags_to_go_struct()
	local bufnr = vim.api.nvim_get_current_buf()
	local node = ts_utils.get_node_at_cursor()
	if not node then
		print("No Treesitter node found at cursor")
		return
	end

	-- Traverse upward until we find a node representing a Go struct.
	local struct_node = node
	while struct_node do
		if struct_node:type() == "struct_type" then
			break
		end
		struct_node = struct_node:parent()
	end

	if not struct_node or struct_node:type() ~= "struct_type" then
		print("Not inside a Go struct")
		return
	end

	-- Find the field declaration list inside the struct node.
	local field_list_node = nil
	for child in struct_node:iter_children() do
		if child:type() == "field_declaration_list" then
			field_list_node = child
			break
		end
	end

	if not field_list_node then
		print("No field list found in struct")
		return
	end

	-- Collect all field modifications first, then apply them all at once
	local modifications = {}
	local field_count = 0

	-- Iterate over each field declaration and add a JSON tag if missing.
	for field in field_list_node:iter_children() do
		if field:type() == "field_declaration" then
			local start_row, _, _, _ = field:range()

			-- Get the full text of the line where the field is declared.
			local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]

			-- Skip this field if it already contains a tag (backticks denote tags).
			if not line:find("`") then
				local field_names = {}

				-- A field_declaration can declare one or more identifiers.
				for child in field:iter_children() do
					local ctype = child:type()
					if ctype == "identifier" or ctype == "field_identifier" then
						local name = vim.treesitter.get_node_text(child, bufnr)
						table.insert(field_names, name)
					end
				end

				if #field_names > 0 then
					-- Create a JSON tag using the field name
					local tag_field = field_names[1] -- Take the first field name
					local tag = string.format('`json:"%s"`', tag_field:lower())

					-- Check if there's a comment in the line
					local comment_start = line:find("//")
					local new_line

					if comment_start then
						-- Insert tag before the comment
						new_line = line:sub(1, comment_start - 1):rtrim()
							.. "  "
							.. tag
							.. "  "
							.. line:sub(comment_start)
					else
						-- No comment, just append the tag
						new_line = line .. "  " .. tag
					end

					-- Store the modification to apply later
					table.insert(modifications, {
						row = start_row,
						line = new_line,
					})
					field_count = field_count + 1
				end
			end
		end
	end

	-- Apply all modifications in reverse order to avoid line shifting issues
	table.sort(modifications, function(a, b)
		return a.row > b.row
	end)
	for _, mod in ipairs(modifications) do
		vim.api.nvim_buf_set_lines(bufnr, mod.row, mod.row + 1, false, { mod.line })
	end

	print(string.format("JSON tags added to %d struct fields", field_count))
end

-- Add a string trim method for Lua (since we're using :rtrim())
string.rtrim = function(s)
	return s:gsub("%s+$", "")
end

-- vim.keymap.set("n", "<leader>gt", function()
-- 	add_json_tags_to_go_struct()
-- end, { noremap = true, silent = true, desc = "Add json tags to struct [Go]" })

-- vim.keymap.set("n", "<leader>he", "oif err != nil {<CR>return , err<CR>}<Esc>k0f,i", { desc = "Go [H]andle [E]rror" })
