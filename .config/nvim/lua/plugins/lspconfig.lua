return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"williamboman/mason.nvim",
			opts = { ui = { border = "rounded" } },
		},
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{
			"b0o/SchemaStore.nvim",
			lazy = true,
			version = false, -- last release is way too old
		},
		{ "j-hui/fidget.nvim", opts = {} },
	},
	config = function()
		-- Set up LSP keymaps and highlighting when a buffer attaches to an LSP
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				-- Configure LSP UI elements to use rounded borders
				local handlers = {
					["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
					["textDocument/signatureHelp"] = vim.lsp.with(
						vim.lsp.handlers.signature_help,
						{ border = "rounded" }
					),
				}
				for method, handler in pairs(handlers) do
					vim.lsp.handlers[method] = handler
				end

				-- Fix semantic tokens for gopls
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
					local semantic = client.config.capabilities.textDocument.semanticTokens
					if semantic then
						client.server_capabilities.semanticTokensProvider = {
							full = true,
							legend = {
								tokenModifiers = semantic.tokenModifiers,
								tokenTypes = semantic.tokenTypes,
							},
							range = true,
						}
					end
				end

				-- Set up buffer-local keymaps
				local function map(keys, func, desc, mode)
					vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("<leader>cn", vim.lsp.buf.rename, "Rename symbol")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
				map("<leader>D", vim.lsp.buf.declaration, "Go to declaration")

				-- Set up document highlight on cursor hold
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

					-- Highlight references when cursor is held
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_group,
						callback = vim.lsp.buf.document_highlight,
					})

					-- Clear highlights when cursor moves
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_group,
						callback = vim.lsp.buf.clear_references,
					})

					-- Clean up highlights when LSP detaches
					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
						callback = function(e)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = e.buf })
						end,
					})
				end
			end,
		})

		-- Configure language servers
		local servers = {
			-- JSON Query Language
			jq = {},

			-- Lua Language Server with custom settings
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},

			-- Go Language Server with enhanced features
			gopls = {
				settings = {
					gopls = {
						gofumpt = true,
						codelenses = {
							gc_details = false,
							generate = true,
							regenerate_cgo = true,
							run_govulncheck = true,
							test = true,
							tidy = true,
							upgrade_dependency = true,
							vendor = true,
						},
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = false,
							rangeVariableTypes = true,
						},
						analyses = {
							nilness = true,
							unusedparams = true,
							unusedwrite = true,
							useany = true,
						},
						usePlaceholders = true,
						completeUnimported = true,
						staticcheck = true,
						directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
						semanticTokens = false,
					},
				},
			},

			hadolint = {},
			yamlls = {
				-- Have to add this for yamlls to understand that we support line folding
				capabilities = {
					textDocument = {
						foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						},
					},
				},
				-- lazy-load schemastore when needed
				on_new_config = function(new_config)
					new_config.settings.yaml.schemas = vim.tbl_deep_extend(
						"force",
						new_config.settings.yaml.schemas or {},
						require("schemastore").yaml.schemas()
					)
				end,
				settings = {
					redhat = { telemetry = { enabled = false } },
					yaml = {
						keyOrdering = false,
						format = {
							enable = true,
						},
						validate = true,
						schemaStore = {
							-- Must disable built-in schemaStore support to use
							-- schemas from SchemaStore.nvim plugin
							enable = false,
							-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
							url = "",
						},
					},
				},
			},
			bashls = {},
			shellcheck = {},
		}

		-- Install additional formatting tools
		local ensure_installed = vim.tbl_keys(servers)
		vim.list_extend(ensure_installed, { "stylua" })
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		-- Set up LSP servers through mason-lspconfig
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = require("blink-cmp").get_lsp_capabilities()
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		-- Configure custom LSP servers not managed by mason
		local lspconfig = require("lspconfig")
		local configs = require("lspconfig.configs")

		-- CWL Language Server
		if not configs.cwl_lsp then
			configs.cwl_lsp = {
				default_config = {
					cmd = { "benten-ls" },
					root_dir = lspconfig.util.root_pattern(".git"),
					filetypes = { "cwl" },
				},
			}
		end
		lspconfig.cwl_lsp.setup({})

		-- Nix Language Server
		if not configs.nix_lsp then
			configs.nix_lsp = {
				default_config = {
					cmd = { "nil" },
					root_dir = lspconfig.util.root_pattern(".git"),
					filetypes = { "nix" },
				},
			}
		end
		lspconfig.nix_lsp.setup({})
	end,
}
