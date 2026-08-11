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

require("ui")
require("editor")
require("lsp")
-- Not "debug" and not "dap": the first collides with Lua's standard library
-- (package.loaded.debug is already taken), the second with nvim-dap's module.
require("debugging")

require("keymaps")
require("autocmds")
