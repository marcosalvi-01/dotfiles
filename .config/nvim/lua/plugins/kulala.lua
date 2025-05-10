return {
	"mistweaverco/kulala.nvim",
	ft = "http",
	opts = {
		default_view = "body",
		-- default_view = "headers_body",
		icons = {
			inlay = {
				loading = "",
				done = "",
				error = "",
			},
			lualine = "󱜿",
		},
		halt_on_error = false,
		show_request_summary = true,
		disable_script_print_output = false,

		ui = {
			report = {
				-- possible values: true | false | "on_error"
				show_script_output = true,
				-- possible values: true | false | "on_error" | "failed_only"
				show_asserts_output = true,
				-- possible values: true | false
				show_summary = true,
			},
		},
	},
}
