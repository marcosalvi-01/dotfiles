return {
	"nvim-java/nvim-java",
	config = function()
		require("java").setup()
		require("lspconfig").jdtls.setup({
			handlers = {
				["language/status"] = function(_, result)
					-- Print or whatever.
				end,
				["$/progress"] = function(_, result, ctx)
					-- disable progress updates.
				end,
			},
		})
	end,
	ft = "java",
}
