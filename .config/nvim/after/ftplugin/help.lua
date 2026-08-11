-- q closes help instead of typing :q<CR>
vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close" })
