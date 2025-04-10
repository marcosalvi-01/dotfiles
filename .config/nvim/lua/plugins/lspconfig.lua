return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
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
			harper_ls = {
				settings = {
					["harper-ls"] = {
						linters = {
							SentenceCapitalization = false,
						},
						markdown = {
							IgnoreLinkTitle = false,
						},
						diagnosticSeverity = "hint",
						isolateEnglish = true,
					},
				},
			},
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

		-- -------HARPER LSP KEYMAP-------
		-- Store visibility state
		local diagnostics_visible = false

		-- Toggle keybinding
		vim.keymap.set("n", "<leader>th", function()
			-- Toggle the state
			diagnostics_visible = not diagnostics_visible

			-- Refresh diagnostics display
			vim.diagnostic.reset()
			vim.cmd("e") -- Refresh buffer to trigger diagnostics update

			-- Provide feedback
			local state = diagnostics_visible and "enabled" or "disabled"
			vim.notify("Harper diagnostics " .. state, vim.log.levels.INFO)
		end, { desc = "Toggle Harper LSP diagnostics" })

		-- Filter function for diagnostics
		local function filter_diagnostics(diagnostic)
			-- Always show non-Harper diagnostics
			if diagnostic.source ~= "Harper" then
				return true
			end

			-- Only show Harper diagnostics if enabled
			return diagnostics_visible
		end

		-- Override the diagnostics handler
		vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ctx, config)
			-- Filter diagnostics before processing
			result.diagnostics = vim.tbl_filter(filter_diagnostics, result.diagnostics)
			vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
		end, {})
	end,
}
