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
					-- Create a JSON tag using the field names.
					-- (If you want to transform the names, e.g. make the first letter lowercase, adjust this logic.)
					local tag_field = table.concat(field_names, ",")
					local tag = string.format(' `json:"%s"`', tag_field)
					local new_line = line .. tag

					-- Update the buffer with the new line.
					vim.api.nvim_buf_set_lines(bufnr, start_row, start_row + 1, false, { new_line })
				end
			end
		end
	end

	print("JSON tags added to all struct fields")
end

-- Map the function to <leader>jt in normal mode (adjust the keymap as needed).
vim.keymap.set("n", "<leader>jt", function()
	add_json_tags_to_go_struct()
end, { noremap = true, silent = true })

local currently_enabled = vim.lsp.inlay_hint.is_enabled()
vim.lsp.inlay_hint.enable(not currently_enabled)
