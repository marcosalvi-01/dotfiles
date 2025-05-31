return {
	"stevearc/conform.nvim",
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>r",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[R]eformat buffer",
		},
	},
	opts = {
		formatters = {
			kulala = {
				command = "kulala-fmt",
				args = { "format", "$FILENAME" },
				stdin = false,
			},
			nixpkgs_fmt = {
				command = "nixpkgs-fmt",
			},
		},
		notify_on_error = false,
		format_on_save = false,
		formatters_by_ft = {
			lua = { "stylua" },
			json = { "jq" },
			zsh = { "beautysh" },
			sh = { "beautysh" },
			nix = { "nixpkgs_fmt" },
			markdown = { "prettier" },
			jsonc = { "biome" },
			python = { "black" },
			yaml = { "prettier" },
			go = { "goimports", "gofumpt" },
			xml = { "xmlformatter" },
			css = { "prettier" },
			http = { "kulala-fmt" },
			kotlin = { "kfmt" },
			html = { "prettier" },
			htmlangular = { "prettier" },
			scss = { "prettier" },
			c = { "clang" },
			sql = { "sleek" },
		},
	},
}
