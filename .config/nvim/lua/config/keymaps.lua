local function create_prefix_mappings(prefix_from, prefix_to, mappings)
	-- Default modes if not specified in mappings
	local default_modes = { "n", "v" }
	for _, mapping in ipairs(mappings) do
		local modes = mapping.modes or default_modes
		local from = mapping.double and prefix_from .. prefix_from or prefix_from
		local to = mapping.double and prefix_to .. prefix_to or prefix_to
		-- If there's a suffix, append it to both from and to
		if mapping.suffix then
			from = from .. mapping.suffix
			to = to .. mapping.suffix
		end
		vim.keymap.set(modes, from, to, mapping.opts or {})
	end
end

-- Define your mappings
local backspace_to_g_mappings = {
	{ double = true },
	{ suffix = "e" },
	{ suffix = "E" },
	{ suffix = "f" },
	{ suffix = "F" },
	{ suffix = "t" },
	{ suffix = "T" },
	{ suffix = "d" },
	{ suffix = "D" },
	{ suffix = "u" },
	{ suffix = "U" },
	{ suffix = "~" },
	{ suffix = "v" },
	{ suffix = "cc" },
	{ suffix = "cip" },
	{ suffix = "x" },
	{ suffix = "i" },
	{ suffix = "r" },
	{ suffix = "gI" },
}
vim.keymap.set({ "n", "v" }, "<BS>", "g")
vim.keymap.set({ "n", "v" }, "<DEL>", "G")
vim.keymap.set({ "n" }, "<DEL><DEL>", "ggVG")
create_prefix_mappings("<BS>", "g", backspace_to_g_mappings)

-- Clear search with esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfixlist" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show [E]rror" })
vim.keymap.set("n", "ge", vim.diagnostic.goto_next, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "gE", vim.diagnostic.goto_prev, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "<leader>gE", vim.cmd.cprev, { desc = "[G]o to previous [E]rror in the Quickfix list" })
vim.keymap.set("n", "<leader>ge", vim.cmd.cnext, { desc = "[G]o to next [E]rror in the Quickfix list" })
vim.keymap.set("n", "<BS>e", vim.diagnostic.goto_next, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "<BS>E", vim.diagnostic.goto_prev, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "<leader><BS>E", vim.cmd.cprev, { desc = "[G]o to previous [E]rror in the Quickfix list" })
vim.keymap.set("n", "<leader><BS>e", vim.cmd.cnext, { desc = "[G]o to next [E]rror in the Quickfix list" })

-- Remap arrows
vim.keymap.set({ "n", "v" }, "<Left>", "h")
vim.keymap.set({ "n", "v" }, "<Right>", "l")
vim.keymap.set({ "n", "v" }, "<Up>", "gk")
vim.keymap.set({ "n", "v" }, "<Down>", "gj")

-- Go handle error
vim.keymap.set("n", "<leader>he", "oif err != nil {<CR>return err<CR>}<Esc>k$b", { desc = "[H]andle [E]rror" })

-- Move lines
-- vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selected line down one line" })
-- vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selected line up one line" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving the cursor" })

vim.keymap.set("n", ",", ";")
vim.keymap.set("n", ";", ",")

vim.keymap.set("n", "<Home>", "_")
vim.keymap.set("n", "<End>", "$")

vim.keymap.set("n", "<PageUp>", "<C-u>zz")
vim.keymap.set("n", "<PageDown>", "<C-d>zz")

vim.keymap.set("n", "Q", "`", { remap = true })

vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

vim.keymap.set("n", "<C-o>", "<C-o>zz")
vim.keymap.set("n", "<C-i>", "<C-i>zz")

vim.keymap.set("n", "H", "~")

vim.keymap.set("n", "vv", "viw")

vim.keymap.set("n", "s", "i<CR><Esc>")

vim.keymap.set("v", "p", '"_dP')
vim.keymap.set("v", "<leader>p", "p")

-- using ctrl + h because kitty seems to interpret ctrl + backspace as that, don't know w
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word in insert mode" })

vim.keymap.set("n", "ZF", "ZQ", { desc = "Quit without saving" })

vim.keymap.set(
	"n",
	"<leader>w",
	"<cmd>silent! wa<cr><cmd>echo 'All buffer changes written'<cr>",
	{ desc = "[W]rite all buffer" }
)

vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "Open file bowser (Oil)" })

vim.keymap.set("n", "<leader>nl", "<cmd>Noice telescope<cr>", { desc = "Open [N]oice [L]ogs" })

vim.keymap.set("n", "<leader>osw", "<cmd>set wrap<cr>", { desc = "([O]ptions) [S]et [W]rap" })

vim.keymap.set("n", "<Enter>", "o<Esc>", { desc = "Add new line under cursor and move to it in normal mode" })
vim.keymap.set("n", "<S-CR>", "m`O<Esc>``", { desc = "Add new line before the current one" })
