--------------------------------------------------------------------------------
-- Python
--------------------------------------------------------------------------------
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

-- Debug a single test or function under the cursor (pytest, unittest).
-- Needs debugpy in the same environment as the code.
vim.keymap.set("n", "<leader>dn", function()
  require("dap-python").test_method()
end, { buffer = true, desc = "Debug: test under cursor" })

vim.keymap.set("n", "<leader>df", function()
  require("dap-python").test_class()
end, { buffer = true, desc = "Debug: test class" })

vim.keymap.set("v", "<leader>ds", function()
  require("dap-python").debug_selection()
end, { buffer = true, desc = "Debug: selection" })
