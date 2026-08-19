--------------------------------------------------------------------------------
-- init.lua — entry point
--------------------------------------------------------------------------------
-- Order matters:
--   1. leader BEFORE any keymap (otherwise <leader> is recorded as "\")
--   2. options before plugins (some read them during setup)
--   3. packages.lua clones plugins and puts them on the runtimepath
--   4. everything after that assumes the plugins are available
--------------------------------------------------------------------------------

if vim.fn.has("nvim-0.12") == 0 then
  vim.notify(
    "This config requires Neovim 0.12+ (vim.pack). Found: " .. tostring(vim.version()),
    vim.log.levels.ERROR
  )
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("packages")

-- Keymaps go BEFORE the plugin setups, which-key's in particular. which-key
-- builds its prefix tree from the keymaps that exist when it initialises, so
-- anything registered after wk.setup() can be missing from the popup.
--
-- Safe this early: keymaps.lua only needs fzf-lua to be on the runtimepath
-- (packages.lua did that), not configured. Mappings that point at user
-- commands like :FormatToggle resolve when pressed, not when defined.
require("keymaps")

require("ui")
require("editor")
require("lsp")
-- Not "debug" and not "dap": the first collides with Lua's standard library
-- (package.loaded.debug is already taken), the second with nvim-dap's module.
require("debugging")

require("autocmds")
