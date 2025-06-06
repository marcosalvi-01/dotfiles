return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",

		-- TODO: remove once https://github.com/samiulsami/cmp-go-deep is archived
		{
			"samiulsami/cmp-go-deep",
			dependencies = {
				"kkharji/sqlite.lua",
				"saghen/blink.compat",
			},
		},
	},
	event = "VeryLazy",
	version = "*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		cmdline = {
			enabled = true,
			---@diagnostic disable-next-line: assign-type-mismatch
			sources = function()
				local type = vim.fn.getcmdtype()
				if type == "/" or type == "?" then
					return { "buffer" }
				end
				if type == ":" or type == "@" then
					return { "cmdline", "path" }
				end
				return {}
			end,
			completion = {
				menu = { auto_show = true },
				ghost_text = { enabled = true },
			},
			keymap = {
				preset = "inherit",
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
			},
		},

		keymap = {
			preset = "default",
			["<PageUp>"] = {
				function(cmp)
					cmp.scroll_documentation_up(4)
				end,
			},
			["<PageDown>"] = {
				function(cmp)
					cmp.scroll_documentation_down(4)
				end,
			},
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		sources = {
			min_keyword_length = function(ctx)
				-- only applies when typing a command, doesn't apply to arguments
				if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
					return 2
				elseif vim.bo.filetype == "markdown" then
					return 2
				end
				return 0
			end,
			default = {
				"go_deep", -- TODO: remove once https://github.com/samiulsami/cmp-go-deep is archived

				"lazydev",
				"lsp",
				"path",
				"snippets",
				"buffer",
				"dadbod",
			},
			providers = {

				-- TODO: remove once https://github.com/samiulsami/cmp-go-deep is archived
				go_deep = {
					name = "go_deep",
					module = "blink.compat.source",
					min_keyword_length = 3,
					max_items = 5,
					---@module "cmp_go_deep"
					---@type cmp_go_deep.Options
					opts = {
						-- See below for configuration options
						get_documentation_implementation = "hover",
						get_package_name_implementation = "treesitter",
					},
				},

				snippets = {
					opts = {
						search_paths = { "~/.config/nvim/snips/" },
					},
				},
				dadbod = {
					name = "Dadbod",
					module = "vim_dadbod_completion.blink",
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				buffer = {
					-- keep case of first char
					transform_items = function(a, items)
						local keyword = a.get_keyword()
						local correct, case
						if keyword:match("^%l") then
							correct = "^%u%l+$"
							case = string.lower
						elseif keyword:match("^%u") then
							correct = "^%l+$"
							case = string.upper
						else
							return items
						end

						-- avoid duplicates from the corrections
						local seen = {}
						local out = {}
						for _, item in ipairs(items) do
							local raw = item.insertText
							if raw:match(correct) then
								local text = case(raw:sub(1, 1)) .. raw:sub(2)
								item.insertText = text
								item.label = text
							end
							if not seen[item.insertText] then
								seen[item.insertText] = true
								table.insert(out, item)
							end
						end
						return out
					end,
				},
			},
		},
		completion = {
			list = {
				selection = {
					preselect = true,
					-- auto_insert = false,
					auto_insert = function(ctx)
						return ctx.mode == "cmdline"
					end,
				},
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
					},
				},
				border = "rounded",
				scrolloff = 1,
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 250,
				window = {
					border = "rounded",
				},
			},
			ghost_text = { enabled = true },
		},
		signature = {
			enabled = true,
			window = {
				border = "rounded",
				show_documentation = false,
				-- now this works, if getting an error when showing the signature, disable
				treesitter_highlighting = true,
			},
		},
	},
	opts_extend = { "sources.default" },
}
