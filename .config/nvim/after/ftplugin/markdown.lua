--------------------------------------------------------------------------------
-- Markdown
--------------------------------------------------------------------------------
vim.opt_local.wrap = true
vim.opt_local.linebreak = true -- break on spaces, not mid-word
vim.opt_local.breakindent = true
vim.opt_local.conceallevel = 2 -- required by render-markdown
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2

-- Move by screen lines, otherwise a long paragraph is a single jump
vim.keymap.set("n", "j", "gj", { buffer = true })
vim.keymap.set("n", "k", "gk", { buffer = true })

-- Spell checking. On first use Neovim offers to download pl.utf-8.spl.
-- vim.opt_local.spell = true
-- vim.opt_local.spelllang = { "pl", "en" }
