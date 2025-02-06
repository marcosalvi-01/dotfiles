return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("noice").setup({
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				-- override = {
				-- 	["vim.lsp.util.convert_input_to_markdown_lines"] = false,
				-- 	["vim.lsp.util.stylize_markdown"] = false,
				-- 	-- ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				-- },

				-- disable noice signature help (using blink-cmp's)
				signature = {
					enabled = false,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = false, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
			commands = {
				history = {
					view = "confirm",
				},
			},
		})

		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { link = "FloatBorder" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { link = "Title" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { link = "FloatBorder" })
	end,
}
