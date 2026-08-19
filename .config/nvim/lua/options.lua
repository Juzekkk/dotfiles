--------------------------------------------------------------------------------
-- GLOBAL OPTIONS
--------------------------------------------------------------------------------
local o = vim.o

-- Disable netrw. nvim-tree replaces it and the two fight over directory
-- buffers if both are active. Must run before netrw loads, so it lives here
-- rather than next to the nvim-tree setup.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- UX
o.autowriteall = true
o.splitright = true
o.splitbelow = true
o.swapfile = false
o.undofile = true
o.clipboard = "unnamedplus"
o.scrolloff = 10
o.confirm = true -- prompt instead of "E37: No write since last change"

-- Indentation (defaults; overridden per language in after/ftplugin/)
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

-- UI
o.showcmd = false
o.number = true
o.relativenumber = true
o.showtabline = 1
o.signcolumn = "yes"
o.breakindent = true
o.updatetime = 250
o.showmode = false
o.laststatus = 3
-- One place that decides the border style for every floating window.
-- "solid" draws the border cells as plain whitespace instead of box-drawing
-- characters. Combined with the border highlights flattened in ui.lua, a float
-- becomes a padded panel with no visible frame, which is what NvChad does.
-- Change this to "rounded", "single" or "none" and everything follows.
vim.g.ui_border = "solid"
o.winborder = vim.g.ui_border
o.guicursor = "n-v-sm:block,i-t-ci-ve-c:ver25,r-cr-o:hor20"

-- WAS: vim.g.termguicolors = true
-- That sets a global variable named "termguicolors", not the option.
o.termguicolors = true

vim.opt.fillchars = { eob = " ", fold = " " }

-- Search
o.ignorecase = true
o.smartcase = true

-- Folds: treesitter, everything open on load.
-- lsp.lua swaps foldexpr for the LSP one when the server supports it.
o.foldenable = true
o.foldlevel = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
o.foldcolumn = "0"

-- Completion (blink.cmp reads these)
o.completeopt = "menu,menuone,noselect,popup,fuzzy"
