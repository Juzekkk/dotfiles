--------------------------------------------------------------------------------
-- GLOBAL KEYMAPS
--------------------------------------------------------------------------------
-- Buffer-local keymaps live where they belong:
--   LSP        -> lua/lsp.lua (LspAttach)
--   git hunks  -> lua/ui.lua (gitsigns on_attach)
--   debug      -> lua/debugging.lua
--   per language -> after/ftplugin/*.lua
--------------------------------------------------------------------------------
local map = vim.keymap.set
local fzf = require("fzf-lua")

--------------------------------------------------------------------------------
-- Basics
--------------------------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close buffer" })

--------------------------------------------------------------------------------
-- VS Code style editing
--------------------------------------------------------------------------------
-- Alt+j / Alt+k moves a line or a selection (Alt+arrows in VS Code)
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the selection after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Paste over a selection without clobbering the register
map("v", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

--------------------------------------------------------------------------------
-- Files and search
--------------------------------------------------------------------------------
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
map("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file in tree" })
map("n", "<C-p>", fzf.files, { desc = "Find file" })
map("n", "<leader>f", fzf.files, { desc = "Find file" })
map("n", "<leader>/", fzf.live_grep, { desc = "Grep project" })
map("n", "<leader>b", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>.", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>k", fzf.helptags, { desc = "Help tags" })
map("n", "<leader>'", fzf.resume, { desc = "Resume last search" })
map("n", "<leader>z", fzf.zoxide, { desc = "Zoxide" })

-- VS Code command-palette style: files, buffers and LSP symbols at once
map("n", "<leader><leader>", fzf.global, { desc = "Search everything" })

map("n", "<leader>sc", fzf.git_bcommits, { desc = "Buffer commits" })
map("n", "<leader>sb", fzf.git_branches, { desc = "Branches" })
map("n", "<leader>sC", fzf.git_commits, { desc = "Commits" })
map("n", "<leader>ss", fzf.git_status, { desc = "Git status" })
map("n", "<leader>sk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>sw", fzf.grep_cword, { desc = "Grep word under cursor" })

--------------------------------------------------------------------------------
-- Working directory
--------------------------------------------------------------------------------
-- Jump the cwd to the git root of the current file. Useful when you opened a
-- file by path and the project context ended up somewhere else.
map("n", "<leader>cd", function()
  local root = vim.fs.root(0, { ".git", "Cargo.toml", "pyproject.toml" })
  if not root then
    vim.notify("No project root found above this file", vim.log.levels.WARN)
    return
  end
  vim.cmd.cd(root)
  vim.notify("cwd: " .. root)
end, { desc = "cd to project root" })

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------
map("n", "<leader>xl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xx", fzf.diagnostics_document, { desc = "Document diagnostics" })
map("n", "<leader>xX", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })
-- ]d and [d work by default since Neovim 0.11, no mapping needed

--------------------------------------------------------------------------------
-- Toggles
--------------------------------------------------------------------------------
map("n", "<leader>tf", "<cmd>FormatToggle<CR>", { desc = "Format on save" })
map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Inline git blame" })
map("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Inlay hints" })

--------------------------------------------------------------------------------
-- Diagnostic noise
--------------------------------------------------------------------------------
-- Saving half-written Rust means clippy flags nearly every line, and the
-- end-of-line messages bury the code. <leader>td cycles three levels. Gutter
-- signs stay on in all of them, so you never lose track of which lines have
-- problems.
--
--   inline  message at the end of every affected line (default)
--   cursor  only the line under the cursor, printed in full underneath it
--   off     gutter signs only
--
-- To also drop warnings and keep just errors, add
-- severity = { min = vim.diagnostic.severity.ERROR } to the virtual_text table.
local diag_levels = { "inline", "cursor", "off" }
local diag_level = 1

map("n", "<leader>td", function()
  diag_level = diag_level % #diag_levels + 1
  local level = diag_levels[diag_level]
  vim.diagnostic.config({
    virtual_text = level == "inline" and { spacing = 2, prefix = "\u{25CF}" } or false,
    virtual_lines = level == "cursor" and { current_line = true } or false,
  })
  vim.notify("Diagnostics: " .. level)
end, { desc = "Cycle diagnostic display" })

-- Total silence, gutter signs included
map("n", "<leader>tD", function()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify("Diagnostics " .. (on and "off" or "on"))
end, { desc = "Diagnostics on/off" })

-- Completion popup, ghost text and signature help. Read by the `enabled`
-- function in editor.lua.
map("n", "<leader>ts", function()
  vim.g.completion_enabled = vim.g.completion_enabled == false
  if not vim.g.completion_enabled then
    require("blink.cmp").hide() -- close the menu if one is already open
  end
  vim.notify("Completion: " .. (vim.g.completion_enabled and "on" or "off"))
end, { desc = "Completion on/off" })
map("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Line wrap" })
-- The vertical bar some editors draw at a fixed column is 'colorcolumn'.
-- It is off everywhere in this config; turn it on per buffer if you want it.
map("n", "<leader>tc", function()
  vim.wo.colorcolumn = vim.wo.colorcolumn == "" and "100" or ""
end, { desc = "Column guide" })

--------------------------------------------------------------------------------
-- Floating terminal
--------------------------------------------------------------------------------
-- ~20 lines instead of lazygit.nvim + plenary. Works for any TUI command.
local function float_term(cmd)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.9),
    height = math.floor(vim.o.lines * 0.9),
    row = math.floor(vim.o.lines * 0.05),
    col = math.floor(vim.o.columns * 0.05),
    border = vim.g.ui_border,
  })
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      vim.cmd.checktime() -- reload buffers changed underneath us
    end,
  })
  vim.cmd.startinsert()
end

map("n", "<leader>g", function()
  float_term("lazygit")
end, { desc = "LazyGit" })

map("n", "<leader>T", function()
  float_term(vim.o.shell)
end, { desc = "Terminal" })

map("t", "<C-\\><C-n>", [[<C-\><C-n>]], { desc = "Normal mode" })
