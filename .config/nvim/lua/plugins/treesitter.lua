return {
	"nvim-treesitter/nvim-treesitter",
	config = function()
		require("nvim-treesitter.configs").setup({
			-- Core functionality
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},

			-- Indentation support
			indent = {
				enable = true,
				disable = { "cwl", "json" },
			},

			-- Incremental selection based on the named nodes from the grammar
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<leader>v",
					node_incremental = "<leader>v",
					scope_incremental = "<leader>i",
					node_decremental = "<leader>V",
				},
			},

			-- Parser installation settings
			ensure_installed = {
				"c",
				"go",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			sync_install = false, -- Install parsers asynchronously
			auto_install = true, -- Automatically install missing parsers
			ignore_install = { "javascript" },
		})
	end,
}
