-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfixlist" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show [E]rror" })
vim.keymap.set("n", "ge", vim.diagnostic.goto_next, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "gE", vim.diagnostic.goto_prev, { desc = "[G]o to next [E]rror" })
vim.keymap.set("n", "<leader>gE", vim.cmd.cprev, { desc = "[G]o to previous [E]rror in the Quickfix list" })
vim.keymap.set("n", "<leader>ge", vim.cmd.cnext, { desc = "[G]o to next [E]rror in the Quickfix list" })

-- Remap arrows
vim.keymap.set({ "n", "v" }, "<Left>", "h")
vim.keymap.set({ "n", "v" }, "<Right>", "l")
vim.keymap.set({ "n", "v" }, "<Up>", "gk")
vim.keymap.set({ "n", "v" }, "<Down>", "gj")

-- Backspace as 'g'
vim.keymap.set({ "n", "v" }, "<BS>", "g")
-- vim.keymap.set({ "n", "v" }, "<BS><BS>", "gg", { remap = true })
-- vim.keymap.set({ "n", "v" }, "<DEL>", "G", { remap = true })
-- vim.keymap.set({ "n", "v" }, "<S-BS>", "G", { remap = true })

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

--vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "[W]rite buffer" })
vim.keymap.set(
	"n",
	"<leader>w",
	"<cmd>silent! wa<cr><cmd>echo 'All buffer changes written'<cr>",
	{ desc = "[W]rite all buffer" }
)

vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "Open file bowser (Oil)" })

vim.keymap.set("n", "<leader>nl", "<cmd>Noice telescope<cr>", { desc = "Open [N]oice [L]ogs" })

vim.keymap.set("n", "<leader>osw", "<cmd>set wrap<cr>", { desc = "([O]ptions) [S]et [W]rap" })
