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
-- Diagnostic display
--------------------------------------------------------------------------------
-- Four levels, cycled with <leader>td. Gutter signs stay on in every one of
-- them, so you never lose track of which lines have problems.
--
--   float   nothing inline; a window opens when the cursor rests on a problem
--           (default)
--   inline  message at the end of every affected line
--   cursor  full message printed under the cursor line, no window
--   off     gutter signs only
--
-- The float shows the same text as <leader>rD. rust-analyzer ships the
-- cargo-rendered diagnostic -- code frame, carets, notes, the lot -- in the
-- LSP diagnostic's data field, and the formatter below prefers it over the
-- one-line message. Other languages have no rendered field and fall back to
-- the plain message, so this costs them nothing.
--
-- To keep only errors and drop warnings, add
-- severity = { min = vim.diagnostic.severity.ERROR } to the virtual_text table.

-- rustaceanvim asks cargo for ANSI-coloured output so that its own
-- :RustLsp renderDiagnostic can turn the escape codes into real highlights.
-- open_float does no such thing, so without this they land in the window as
-- literal "ESC[1m" noise. Matches a CSI sequence: ESC [ digits/semicolons letter.
local ANSI = "\27%[[%d;]*%a"

-- Returns the cargo-rendered text for a diagnostic, or nil if it has none.
local function rendered_of(diag)
  local rendered = vim.tbl_get(diag, "user_data", "lsp", "data", "rendered")
  if type(rendered) == "string" and rendered ~= "" then
    return (rendered:gsub(ANSI, ""):gsub("%s+$", ""))
  end
  return nil
end

local float_group = vim.api.nvim_create_augroup("diagnostic-float", { clear = true })

local function set_float_on_hover(enabled)
  vim.api.nvim_clear_autocmds({ group = float_group })
  if not enabled then
    return
  end
  vim.api.nvim_create_autocmd("CursorHold", {
    group = float_group,
    callback = function()
      -- Never stack floats. If one is already open -- hover, completion docs,
      -- signature help, or the previous diagnostic float -- do nothing. The
      -- diagnostic float closes itself on CursorMoved, so the next time the
      -- cursor comes to rest there is nothing in the way.
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
          return
        end
      end

      local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      local has_rendered = false
      for _, diag in ipairs(vim.diagnostic.get(0, { lnum = lnum })) do
        if rendered_of(diag) then
          has_rendered = true
          break
        end
      end

      local opts = {
        -- "cursor" means the cursor has to sit inside the diagnostic's range,
        -- not merely somewhere on the line. Change to "line" if you want the
        -- window whenever the line has a problem anywhere.
        scope = "cursor",
        focus = false, -- do not jump into the window
        border = vim.g.ui_border,
        max_width = 100, -- cargo frames are wider than a hover
        max_height = 20,
        header = "",
        source = "if_many",
        format = function(diag)
          local rendered = rendered_of(diag)
          if rendered then
            return rendered
          end
          -- rust-analyzer emits its suggested fix as a separate diagnostic
          -- ("remove the whole `use` item"), which the cargo frame above
          -- already spells out. Returning nil drops it from the window.
          if has_rendered then
            return nil
          end
          return diag.message
        end,
      }

      if has_rendered then
        -- Numbering each entry indents every following line and knocks the
        -- carets out of line with the code above them. The source name would
        -- be tacked onto the end of the frame for the same reason.
        opts.prefix = ""
        opts.source = false
      end

      vim.diagnostic.open_float(opts)
    end,
  })
end

-- Delay before the window appears is 'updatetime' (250ms, set in options.lua).
local diag_levels = { "float", "inline", "cursor", "off" }
local diag_level = 1

local function apply_diag_level()
  local level = diag_levels[diag_level]
  vim.diagnostic.config({
    virtual_text = level == "inline" and { spacing = 2, prefix = "\u{25CF}" } or false,
    virtual_lines = level == "cursor" and { current_line = true } or false,
  })
  set_float_on_hover(level == "float")
end

apply_diag_level() -- silent on startup

map("n", "<leader>td", function()
  diag_level = diag_level % #diag_levels + 1
  apply_diag_level()
  vim.notify("Diagnostics: " .. diag_levels[diag_level])
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
