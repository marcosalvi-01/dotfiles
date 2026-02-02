---@module "lazy"
---@type LazySpec
return {
	{
		event = "VeryLazy",
		-- Provides treesitter queries for mini.ai textobjects
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			-- Define languages to ensure are installed at startup
			local core_languages = {
				"c",
				"go",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"yaml",
				"sql",
				"json",
				"gitcommit",
				"turtle",
				"java",
				"make",
				"python",
				"toml",
				"typescript",
				"dockerfile"
			}

			ts.install(core_languages)

			-- Function to get all installed parser languages
			local function get_installed_parsers()
				local parsers = {}
				-- Find all installed parser files
				local parser_files = vim.api.nvim_get_runtime_file("parser/*.so", true)

				-- Extract language names from parser filenames
				for _, file in ipairs(parser_files) do
					local lang = file:match("parser/([^/]+)%.so$")
					if lang then
						table.insert(parsers, lang)
					end
				end

				return parsers
			end

			local function get_filetypes_for_installed_parsers()
				local installed = get_installed_parsers()
				local filetypes = vim.iter(installed)
					:map(function(lang)
						return vim.treesitter.language.get_filetypes(lang)
					end)
					:flatten()
					:totable()
				return filetypes
			end

			local ts_filetypes = get_filetypes_for_installed_parsers()
			local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

			-- Enable treesitter for filetypes with installed parsers
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				desc = "Enable treesitter highlighting and indentation",
				pattern = ts_filetypes,
				callback = function(event)
					local buf = event.buf
					local ft = event.match
					local lang = vim.treesitter.language.get_lang(ft) or ft

					pcall(vim.treesitter.start, buf, lang)

					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},
}
