return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",

		-- Supermaven
		{
			"supermaven-inc/supermaven-nvim",
			opts = {
				disable_inline_completion = true,
				disable_keymaps = true,
				log_level = "off",
				ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
			},
		},
		{ "Huijiro/blink-cmp-supermaven" },
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
			["<C-s>"] = {
				function(cmp)
					cmp.show_signature()
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
				"supermaven",
				"lazydev",
				"lsp",
				"path",
				"snippets",
				"buffer",
				"dadbod",
			},

			providers = {
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
						local seen, out = {}, {}
						for _, item in ipairs(items) do
							local raw = item.insertText
							if raw:match(correct) then
								local text = case(raw:sub(1, 1)) .. raw:sub(2)
								item.insertText, item.label = text, text
							end
							if not seen[item.insertText] then
								seen[item.insertText] = true
								table.insert(out, item)
							end
						end
						return out
					end,
				},

				-- Supermaven
				supermaven = {
					name = "supermaven",
					module = "blink-cmp-supermaven",
					async = true,
					min_keyword_length = 0,
					should_show_items = require("utils.supermaven_snippets").gate_first_word({
						ignore_case = true,
						by_filetype = {
							lua = { "print", { prefix = "vim." } },
							typescript = { "console*", { exact = "return" } },
							go = { "log*", "ret*", "display*" },
						},
					}),
				},
			},
		},

		completion = {
			list = {
				selection = {
					preselect = true,
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
				window = { border = "rounded" },
			},
			ghost_text = { enabled = true },
		},

		signature = {
			enabled = true,
			window = {
				border = "rounded",
				show_documentation = false,
				treesitter_highlighting = true,
			},
		},
	},

	opts_extend = { "sources.default" },
}
