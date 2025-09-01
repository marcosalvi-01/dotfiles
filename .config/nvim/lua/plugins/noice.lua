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
}
