return {
	"folke/noice.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},

			-- disable noice signature help (using blink-cmp's)
			signature = {
				enabled = false,
			},
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = true,
		},
		commands = {
			history = { view = "confirm" },
		},
		routes = {
			-- Hide any notification containing "Supermaven"
			{
				filter = { event = "notify", find = "Supermaven" },
				opts = { skip = true },
			},
		},
	},
	config = function(_, opts)
		require("noice").setup(opts)

		local format = require("noice.lsp.format")
		local original_format_markdown = format.format_markdown

		-- kotlin-lsp emits 4-backtick fences that Noice misparses.
		format.format_markdown = function(contents)
			local lines = original_format_markdown(contents)
			for i, line in ipairs(lines) do
				local indent, lang = line:match("^(%s*)````+([%w_+-]+)%s*$")
				if lang == "kotlin" then
					lines[i] = indent .. "```" .. lang
				end
			end
			return lines
		end
	end,
}
