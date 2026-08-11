--------------------------------------------------------------------------------
-- EDITING
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- fzf-lua — picker
--------------------------------------------------------------------------------
-- Replaces telescope + plenary + fzf-native + telescope-zoxide.
-- Needs `fzf` and `rg` on PATH.
require("fzf-lua").setup({
  "default-title",
  winopts = {
    height = 0.85,
    width = 0.85,
    -- fzf-lua draws its own frame by default; match everything else
    border = vim.g.ui_border,
    preview = { layout = "flex", horizontal = "right:50%", border = vim.g.ui_border },
  },
  keymap = {
    builtin = {
      ["<C-u>"] = "preview-page-up",
      ["<C-d>"] = "preview-page-down",
      ["<Esc>"] = "hide",
    },
    fzf = {
      ["ctrl-q"] = "select-all+accept", -- send results to quickfix
      ["ctrl-u"] = "half-page-up",
      ["ctrl-d"] = "half-page-down",
    },
  },
  files = { hidden = true },
  grep = {
    hidden = true,
    -- Carried over from your telescope setup: search ignored files too,
    -- but skip .git/
    rg_opts = "--column --line-number --no-heading --color=always --smart-case "
      .. "--hidden --no-ignore --glob '!.git/*' --max-columns=4096 -e",
  },
})

-- fzf-lua takes over vim.ui.select, so LSP code actions and friends get the
-- same look as every other picker.
require("fzf-lua").register_ui_select()

--------------------------------------------------------------------------------
-- nvim-tree — sidebar file explorer
--------------------------------------------------------------------------------
-- Single plugin, no plenary and no nui. netrw is disabled in options.lua.
require("nvim-tree").setup({
  -- Keep the tree root glued to the working directory. Combined with the
  -- VimEnter handler in autocmds.lua, `nvim some/folder` lands you with both
  -- the cwd and the tree root on that folder.
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true, -- highlight the current file in the tree
    update_root = false, -- but never move the root behind your back
  },
  hijack_directories = { enable = true, auto_open = true },
  view = {
    width = 34,
    side = "left",
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty = true, -- collapse a/b/c chains into one line
    indent_markers = { enable = true },
    highlight_git = true,
  },
  filters = {
    dotfiles = false, -- you had hide_dotfiles = false in neo-tree
    custom = { "^\\.git$", "__pycache__", "^\\.venv$" },
  },
  git = { enable = true, ignore = false },
  actions = {
    open_file = {
      quit_on_open = false,
      window_picker = { enable = false },
    },
  },
})

--------------------------------------------------------------------------------
-- conform.nvim — formatting
--------------------------------------------------------------------------------
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    json = { "jq" },
    -- Anything else falls back to the LSP formatter
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function(bufnr)
    if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
      return nil
    end
    return { timeout_ms = 1500, lsp_format = "fallback" }
  end,
})

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.autoformat = vim.b.autoformat == false -- this buffer only
  else
    vim.g.autoformat = vim.g.autoformat == false
  end
  local on = args.bang and vim.b.autoformat ~= false or vim.g.autoformat ~= false
  vim.notify("Format on save: " .. (on and "on" or "off"))
end, { bang = true, desc = "Toggle format-on-save (! = this buffer only)" })

--------------------------------------------------------------------------------
-- blink.cmp — completion
--------------------------------------------------------------------------------
-- One plugin instead of nvim-cmp + 5 sources + LuaSnip. Pinning to the 1.*
-- tag makes it download a prebuilt fuzzy matcher, so nothing compiles here.
require("blink.cmp").setup({
  -- Gate for <leader>ts. blink ANDs this with its own default condition
  -- (buftype ~= "prompt" and vim.b.completion ~= false), so per-buffer
  -- vim.b.completion = false keeps working alongside this global switch.
  -- Covers the popup, ghost text and signature help in one go.
  enabled = function()
    return vim.g.completion_enabled ~= false
  end,
  keymap = {
    preset = "enter", -- <CR> accepts, <C-e> dismisses, <C-n>/<C-p> move
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    -- VS Code behaviour: nothing preselected, docs appear on their own,
    -- ghost text previews the first match.
    list = { selection = { preselect = false, auto_insert = true } },
    menu = { border = vim.g.ui_border, max_height = 12 },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      -- Capped so a long docstring does not swallow the buffer. You had
      -- suggest.floatConfig.maxWidth = 30 in coc-settings.json; shrink these
      -- if that felt better.
      window = { border = vim.g.ui_border, max_width = 70, max_height = 16 },
    },
    ghost_text = { enabled = true },
  },
  signature = {
    enabled = true,
    window = { border = vim.g.ui_border, max_width = 70, max_height = 8 },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
