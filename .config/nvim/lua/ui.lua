--------------------------------------------------------------------------------
-- APPEARANCE
--------------------------------------------------------------------------------
-- Every glyph in this file is written as a \u{...} escape on purpose. Literal
-- Nerd Font characters get mangled when a config is copied through editors,
-- chat clients or terminals, and a mangled sign silently renders as nothing.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Colorscheme
--------------------------------------------------------------------------------
vim.g.everforest_background = "hard" -- "soft" | "medium" | "hard"
vim.g.everforest_enable_italic = 1
vim.g.everforest_disable_italic_comment = 0
vim.g.everforest_transparent_background = 0
vim.g.everforest_ui_contrast = "low" -- "low" | "high"
vim.g.everforest_better_performance = 1
vim.cmd.colorscheme("everforest")

--------------------------------------------------------------------------------
-- Borderless floats
--------------------------------------------------------------------------------
-- vim.g.ui_border is "solid", so Neovim draws each border cell as a space
-- rather than a box-drawing character. That alone is not enough: the space is
-- painted with the *border* highlight, so you still see a frame in a different
-- colour. Linking every border group to its window group makes the ring blend
-- into the float and read as padding.
--
-- This is the same trick behind NvChad's "borderless" telescope style.
--
-- Re-run on ColorScheme, because loading a theme wipes every highlight.
local function flatten_borders()
  local pairs_ = {
    FloatBorder = "NormalFloat",
    -- blink.cmp
    BlinkCmpMenuBorder = "BlinkCmpMenu",
    BlinkCmpDocBorder = "BlinkCmpDoc",
    BlinkCmpSignatureHelpBorder = "BlinkCmpSignatureHelp",
    -- fzf-lua
    FzfLuaBorder = "FzfLuaNormal",
    FzfLuaPreviewBorder = "FzfLuaPreviewNormal",
  }
  for border, window in pairs(pairs_) do
    vim.api.nvim_set_hl(0, border, { link = window })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("flatten-borders", { clear = true }),
  callback = flatten_borders,
})
flatten_borders()

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------
require("mini.icons").setup()
-- Registers mini.icons under the nvim-web-devicons API, so lualine, fzf-lua
-- and nvim-tree pick up icons without a second plugin.
MiniIcons.mock_nvim_web_devicons()

--------------------------------------------------------------------------------
-- Treesitter (main branch)
--------------------------------------------------------------------------------
-- The rewritten plugin does one thing: install and update parsers.
-- Highlighting and indentation are core Neovim features that we turn on here.
require("nvim-treesitter").install({
  "bash",
  "c",
  "diff",
  "git_config",
  "gitcommit",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(ev)
    -- pcall because start() throws for a filetype with no installed parser
    if pcall(vim.treesitter.start) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

--------------------------------------------------------------------------------
-- Statusline
--------------------------------------------------------------------------------
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, (client.name:gsub("language.server", "ls")))
  end
  return "LSP: " .. table.concat(names, ", ")
end

local function python_env()
  local venv = vim.env.CONDA_DEFAULT_ENV or vim.env.VIRTUAL_ENV
  if not venv then
    return ""
  end
  return "venv: " .. vim.fn.fnamemodify(venv, ":t")
end

local function macro()
  local reg = vim.fn.reg_recording()
  return reg == "" and "" or ("recording @" .. reg)
end

require("lualine").setup({
  options = {
    globalstatus = true,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {},
    lualine_c = {
      { "filename", path = 1 },
      { "branch" },
      { "diff" },
      { "diagnostics" },
      { macro },
    },
    lualine_x = {
      { python_env, cond = function() return vim.env.VIRTUAL_ENV ~= nil end },
      { lsp_status },
      { "filetype" },
    },
    lualine_y = { { "progress" }, { "location" } },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
})

--------------------------------------------------------------------------------
-- which-key
--------------------------------------------------------------------------------
-- No custom icons here. which-key ships its own defaults and handles the
-- font fallback itself, which is one less thing that can render as a blank.
local wk = require("which-key")
wk.setup({
  preset = "helix",
  notify = false,
  sort = { "desc" },
  win = { border = vim.g.ui_border },
})

wk.add({
  { "<leader>c", group = "Code" },
  { "<leader>d", group = "Debug" },
  { "<leader>h", group = "Git hunks" },
  { "<leader>r", group = "Rust" },
  { "<leader>s", group = "Search" },
  { "<leader>t", group = "Toggle" },
  { "<leader>x", group = "Diagnostics" },
})

--------------------------------------------------------------------------------
-- Git signs in the gutter
--------------------------------------------------------------------------------
require("gitsigns").setup({
  current_line_blame = false, -- toggle with <leader>tb
  current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")

    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
    map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hd", gs.diffthis, "Diff file")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
  end,
})

--------------------------------------------------------------------------------
-- Markdown
--------------------------------------------------------------------------------
require("render-markdown").setup({
  win_options = {
    wrap = { default = true, rendered = false },
  },
})
