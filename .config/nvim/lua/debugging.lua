--------------------------------------------------------------------------------
-- DEBUGGING
--------------------------------------------------------------------------------
-- nvim-dap-view replaces dap-ui + nvim-nio + nvim-dap-virtual-text. Every view
-- (scopes, stack, breakpoints, REPL, console) shares one window and you switch
-- between them from the winbar.
--------------------------------------------------------------------------------

local dap = require("dap")
local dv = require("dap-view")

dv.setup({
  -- Scopes is more useful than an empty watch list when a session starts
  winbar = { default_section = "scopes" },
  windows = { size = 0.3 }, -- fraction of screen height
  -- Off by default. This is the nvim-dap-virtual-text replacement: variable
  -- values shown inline in the code while stepping.
  virtual_text = { enabled = true, position = "inline" },
  auto_toggle = true, -- open on session start, close when it ends
})

--------------------------------------------------------------------------------
-- Gutter signs
--------------------------------------------------------------------------------
-- Escapes, not literal characters. A glyph that gets stripped somewhere in
-- transit leaves text = "" and the sign renders as nothing at all, which looks
-- exactly like "toggle_breakpoint is broken".
--
-- These are plain geometric shapes from the BMP, not Nerd Font private-use
-- glyphs, so they show up in any monospace font. If you want the Nerd Font
-- look instead, swap in \u{f111} and friends.
--
-- Verify with:  :lua =vim.fn.sign_getdefined("DapBreakpoint")
vim.fn.sign_define("DapBreakpoint", { text = "\u{25CF}", texthl = "DiagnosticError" }) -- ●
vim.fn.sign_define("DapBreakpointCondition", { text = "\u{25C6}", texthl = "DiagnosticWarn" }) -- ◆
vim.fn.sign_define("DapBreakpointRejected", { text = "\u{2716}", texthl = "Comment" }) -- ✖
vim.fn.sign_define("DapLogPoint", { text = "\u{25AA}", texthl = "DiagnosticInfo" }) -- ▪
vim.fn.sign_define("DapStopped", { text = "\u{25B6}", texthl = "DiagnosticWarn", linehl = "Visual" }) -- ▶

--------------------------------------------------------------------------------
-- Python
--------------------------------------------------------------------------------
-- dap-python finds the interpreter itself: $VIRTUAL_ENV first, then .venv/ in
-- the project, then python3 from PATH.
-- Needs: pip install debugpy (in the same environment as your code).
local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
require("dap-python").setup(venv and (venv .. "/bin/python") or "python3")

--------------------------------------------------------------------------------
-- Rust
--------------------------------------------------------------------------------
-- Deliberately empty. rustaceanvim finds codelldb on PATH, builds the target
-- and supplies the configuration itself. Use :RustLsp debuggables, mapped to
-- <leader>rd in after/ftplugin/rust.lua.
--
-- Breakpoints themselves do not need any of this. dap.toggle_breakpoint()
-- places a sign whether or not an adapter is configured, so if you see the ●
-- appear, the breakpoint is registered.
--
-- For a binary outside cargo, uncomment:
-- dap.adapters.codelldb = {
--   type = "server",
--   port = "${port}",
--   executable = { command = "codelldb", args = { "--port", "${port}" } },
-- }

--------------------------------------------------------------------------------
-- Keymaps (VS Code layout)
--------------------------------------------------------------------------------
local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map("<F5>", dap.continue, "Debug: start / continue")
map("<F9>", dap.toggle_breakpoint, "Debug: toggle breakpoint")
map("<F10>", dap.step_over, "Debug: step over")
map("<F11>", dap.step_into, "Debug: step into")
map("<S-F11>", dap.step_out, "Debug: step out")
map("<S-F5>", dap.terminate, "Debug: terminate")

map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("<leader>dB", function()
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
    if cond then
      dap.set_breakpoint(cond)
    end
  end)
end, "Conditional breakpoint")
map("<leader>dc", dap.continue, "Start / continue")
map("<leader>dr", dap.restart, "Restart session")
map("<leader>dt", dap.terminate, "Terminate session")
map("<leader>du", dv.toggle, "Toggle UI")
map("<leader>dl", function()
  require("fzf-lua").dap_breakpoints()
end, "List breakpoints")
map("<leader>de", dv.add_expr, "Watch expression")
vim.keymap.set({ "n", "v" }, "<leader>dh", function()
  dv.hover()
end, { desc = "Inspect value" })
