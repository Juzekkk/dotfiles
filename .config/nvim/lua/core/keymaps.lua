vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymap = vim.keymap

-- Clear search highlights on Escape
keymap.set("n", "<Esc>", ":nohl<CR>", { desc = "Clear search highlights" })

-- Window Navigation (easier split movement)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Exit insert mode in terminal --
-- vim.keymap.set("t", "<C-[>", [[<C-\><C-n>]], { noremap = true, silent = true })
