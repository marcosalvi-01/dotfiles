return {
	{
		event = "VeryLazy",
		-- Provides treesitter queries for mini.ai textobjects
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		event = "VeryLazy",
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts
		opts = {
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
					node_incremental = "v",
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
			textobjects = {
				swap = {
					enable = true,
					swap_next = {
						["<m-up>"] = "@parameter.inner",
					},
					swap_previous = {
						["<m-down>"] = "@parameter.inner",
					},
				},
			},
		},
	},
}
