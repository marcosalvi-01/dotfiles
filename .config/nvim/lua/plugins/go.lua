return {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("go").setup()

		-- Keymaps
		vim.keymap.set("n", "<leader>gat", ":GoAddTag<CR>", { desc = "Go [A]dd [T]ag to struct" })
		vim.keymap.set("n", "<leader>gi", ":GoImpl ", { desc = "[G]o [I]mplement interface" })
		vim.keymap.set("n", "<leader>gc", ":GoCmt<CR>", { desc = "[G]o add [C]omment" })
		vim.keymap.set("n", "<leader>gmt", ":GoModTidy<CR>", { desc = "[G]o [M]od [T]idy" })
		vim.keymap.set("n", "<leader>gfp", ":GoFixPlurals<CR>", { desc = "[G]o [F]ix [P]lurals" })
		vim.keymap.set("n", "<leader>ge", ":GoIfErr<CR>", { desc = "[G]o add if [E]rr" })
		vim.keymap.set("n", "<leader>gfs", ":GoFillStruct<CR>", { desc = "[G]o [F]ill [S]truct" })
		vim.keymap.set("n", "<leader>gfw", ":GoFillSwitch<CR>", { desc = "[G]o [F]ill s[W]itch" })
		vim.keymap.set("n", "<leader><BS>at", ":GoAddTag<CR>", { desc = "Go [A]dd [T]ag to struct" })
		vim.keymap.set("n", "<leader><BS>i", ":GoImpl ", { desc = "[G]o [I]mplement interface" })
		vim.keymap.set("n", "<leader><BS>c", ":GoCmt<CR>", { desc = "[G]o add [C]omment" })
		vim.keymap.set("n", "<leader><BS>mt", ":GoModTidy<CR>", { desc = "[G]o [M]od [T]idy" })
		vim.keymap.set("n", "<leader><BS>fp", ":GoFixPlurals<CR>", { desc = "[G]o [F]ix [P]lurals" })
		vim.keymap.set("n", "<leader><BS>e", ":GoIfErr<CR>", { desc = "[G]o add if [E]rr" })
		vim.keymap.set("n", "<leader><BS>fs", ":GoFillStruct<CR>", { desc = "[G]o [F]ill [S]truct" })
		vim.keymap.set("n", "<leader><BS>fw", ":GoFillSwitch<CR>", { desc = "[G]o [F]ill s[W]itch" })
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
