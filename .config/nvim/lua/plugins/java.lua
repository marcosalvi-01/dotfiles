return {
	"nvim-java/nvim-java",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mason-org/mason.nvim",
	},
	opts = {
		jdtls = {
			version = "v1.46.1",
		},
		java_test = {
			enable = false,
		},
		java_debug_adapter = {
			enable = false,
		},
		spring_boot_tools = {
			enable = false,
		},
		jdk = {
			auto_install = false,
		},
		notifications = {
			dap = false,
		},
	},
	ft = "java",
}
