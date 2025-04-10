vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

-- Sync clipboard
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Tab size
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
-- Use tabs instead of spaces
vim.opt.expandtab = false

-- Linewrap
vim.opt.wrap = false
vim.opt.linebreak = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 6

-- Undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Smartcase
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = false

-- Folding
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"

vim.opt.statuscolumn = "%s%=%{v:relnum?v:relnum:v:lnum} "

vim.opt.updatetime = 50

vim.opt.termguicolors = true

-- Hide the tilde empty lines and fold chars
vim.opt.fillchars:append({ fold = "·", eob = " " })
vim.opt.conceallevel = 2

vim.opt.cmdheight = 0

vim.opt.pumblend = 0
