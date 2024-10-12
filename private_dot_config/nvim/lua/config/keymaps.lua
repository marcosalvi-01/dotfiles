-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Remap arrows
vim.keymap.set({ "n", "v" }, "<Left>", "h")
vim.keymap.set({ "n", "v" }, "<Right>", "l")
vim.keymap.set({ "n", "v" }, "<Up>", "k")
vim.keymap.set({ "n", "v" }, "<Down>", "j")

-- Backspace as 'g'
vim.keymap.set({ "n", "v" }, "<BS>", "g", { remap = true })
vim.keymap.set({ "n", "v" }, "<BS><BS>", "gg", { remap = true })
vim.keymap.set({ "n", "v" }, "<Del>", "G", { remap = true })
vim.keymap.set({ "n", "v" }, "<Del><Del>", "ggVG", { remap = true })

-- Go handle error
vim.keymap.set("n", "<leader>he", "oif err != nil {<CR>return err<CR>}<Esc>k$b", { desc = "[H]andle [E]rror" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-Left>", "<C-w><C-h>", { remap = true, desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-Right>", "<C-w><C-l>", { remap = true, desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-Down>", "<C-w><C-l>", { remap = true, desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w><C-k>", { remap = true, desc = "Move focus to the upper window" })
-- vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { remap = true, desc = "Move focus to the left window" })
-- vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { remap = true, desc = "Move focus to the right window" })
-- vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { remap = true, desc = "Move focus to the lower window" })
-- vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { remap = true, desc = "Move focus to the upper window" })

-- File explorer (netrw)
vim.keymap.set("n", "-", vim.cmd.Ex)

-- Move lines
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selected line down one line" })
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selected line up one line" })

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
