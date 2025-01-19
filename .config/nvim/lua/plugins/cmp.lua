return { -- Autocompletion
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		-- Snippet Engine & its associated nvim-cmp source
		{
			"L3MON4D3/LuaSnip",
			build = (function()
				-- Build Step is needed for regex support in snippets.
				-- This step is not supported in many windows environments.
				-- Remove the below condition to re-enable on windows.
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			config = function()
				local ls = require("luasnip")

				-- move to the next input if possible else do tab
				vim.keymap.set({ "i", "s" }, "<Tab>", function()
					if ls.locally_jumpable() then
						ls.jump(1)
					else
						-- Insert a literal tab character
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", true)
					end
				end, { silent = true })
				vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
					ls.jump(-1)
				end, { silent = true })
			end,
			dependencies = {
				-- `friendly-snippets` contains a variety of premade snippets.
				--    See the README about individual language/framework/plugin snippets:
				--    https://github.com/rafamadriz/friendly-snippets
				{
					"rafamadriz/friendly-snippets",
					config = function()
						require("luasnip.loaders.from_vscode").lazy_load()
					end,
				},
			},
		},
		"saadparwaiz1/cmp_luasnip",

		-- Adds other completion capabilities.
		--  nvim-cmp does not ship with all sources by default. They are split
		--  into multiple repos for maintenance purposes.
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"onsails/lspkind.nvim",
	},
	config = function()
		-- See `:help cmp`
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		luasnip.config.setup({})
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})
		cmp.setup({
			preselect = cmp.PreselectMode.None,
			completion = {
				completeopt = "menu,menuone,preview",
			},
			sorting = {
				priority_weight = 1.0,
				comparators = {
					cmp.config.compare.kind,
					cmp.config.compare.locality,
					cmp.config.compare.recently_used,
					cmp.config.compare.score,
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.scopes,
				},
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			view = {
				entries = { name = "custom", selection_order = "top_down" },
			},
			formatting = {
				expandable_indicator = false,
				fields = { "abbr", "kind", "menu" },
				format = require("lspkind").cmp_format({
					mode = "symbol_text",
					menu = {
						buffer = "[Buf]",
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						nvim_lua = "[Lua]",
						latex_symbols = "[Latex]",
					},
				}),
			},
			window = {
				documentation = cmp.config.window.bordered(),
				completion = cmp.config.window.bordered({
					winhighlight = "Scrollbar:CmpScrollbar,ScrollbarThumb:CmpScrollbarThumb",
					scrolloff = 1,
				}),
			},
			-- For an understanding of why these mappings were
			-- chosen, you will need to read `:help ins-completion`
			--
			-- No, but seriously. Please read `:help ins-completion`, it is really good!
			mapping = cmp.mapping.preset.insert({
				-- Select the [n]ext item
				["<Down>"] = cmp.mapping.select_next_item(),
				-- Select the [p]revious item
				["<Up>"] = cmp.mapping.select_prev_item(),

				-- Scroll the documentation window [b]ack / [f]orward
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),

				-- Accept ([y]es) the completion.
				--  This will auto-import if your LSP supports it.
				--  This will expand snippets if the LSP sent a snippet.
				["<C-y>"] = cmp.mapping.confirm({ select = true }),

				-- If you prefer more traditional completion keymaps,
				-- you can uncomment the following lines
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				--['<Tab>'] = cmp.mapping.select_next_item(),
				--['<S-Tab>'] = cmp.mapping.select_prev_item(),

				-- Manually trigger a completion from nvim-cmp.
				--  Generally you don't need this, because nvim-cmp will display
				--  completions whenever it has completion options available.
				["<C-Space>"] = cmp.mapping.complete({}),

				-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
				--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
			}),
			sources = {
				{
					name = "lazydev",
					-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
					group_index = 0,
				},
				{ name = "nvim_lsp", priority = 8 },
				{ name = "luasnip", priority = 7 },
				{ name = "buffer", priority = 6 },
				{ name = "spell", keyword_length = 3, priority = 5, keyword_pattern = [[\w\+]] },
			},
		})

		cmp.setup.filetype({ "sql" }, {
			sources = {
				{ name = "vim-dadbod-completion" },
				{ name = "buffer" },
			},
		})

		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
