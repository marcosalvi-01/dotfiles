return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod" },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_auto_execute_table_helpers = 1
	end,
	keys = {
		{
			"<leader>db",
			":DBUIToggle<CR>",
			mode = "",
			desc = "Open [D][B]UI (dadbod)",
		},
	},
}
