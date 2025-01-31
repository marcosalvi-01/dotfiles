return {
	"saghen/blink.cmp",
	dependencies = "rafamadriz/friendly-snippets",
	version = "*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
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
			default = {
				"lazydev",
				"lsp",
				"path",
				"snippets",
				"buffer",
				"dadbod",
			},
			providers = {
				dadbod = {
					name = "Dadbod",
					module = "vim_dadbod_completion.blink",
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
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
			window = {
				border = "rounded",
				show_documentation = false,
			},
		},
	},
	opts_extend = { "sources.default" },
}
