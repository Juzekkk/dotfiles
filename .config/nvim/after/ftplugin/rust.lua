--------------------------------------------------------------------------------
-- Rust
--------------------------------------------------------------------------------
-- Runs for every .rs buffer. Keymaps are buffer-local so <leader>r stays out
-- of which-key in other languages.
--------------------------------------------------------------------------------
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

local function map(lhs, cmd, desc)
  vim.keymap.set("n", lhs, cmd, { buffer = true, desc = desc })
end

-- rust-analyzer's grouped code actions, richer than plain vim.lsp.buf.code_action
map("<leader>ca", "<cmd>RustLsp codeAction<CR>", "Rust code action")

-- Running and debugging. `debuggables` builds the target and attaches codelldb
-- itself, so there is no path to type in like in the old config.
map("<leader>rr", "<cmd>RustLsp runnables<CR>", "Runnables")
map("<leader>rd", "<cmd>RustLsp debuggables<CR>", "Debuggables")
map("<leader>rt", "<cmd>RustLsp testables<CR>", "Testables")

-- Diagnostics
map("<leader>re", "<cmd>RustLsp explainError<CR>", "Explain error (rustc --explain)")
map("<leader>rD", "<cmd>RustLsp renderDiagnostic<CR>", "Full cargo-style diagnostic")
map("<leader>rm", "<cmd>RustLsp expandMacro<CR>", "Expand macro")

-- Documentation. Hover gives you the signature; openDocs opens docs.rs for
-- the symbol under the cursor in your browser, which is where the examples are.
map("<leader>ro", "<cmd>RustLsp openDocs<CR>", "Open docs.rs for symbol")

-- Navigation
map("<leader>rp", "<cmd>RustLsp parentModule<CR>", "Parent module")
map("<leader>rc", "<cmd>RustLsp openCargo<CR>", "Open Cargo.toml")

-- Hover plus the list of things you can do with the symbol.
-- Press K again to enter the hover window.
map("K", "<cmd>RustLsp hover actions<CR>", "Hover with actions")
