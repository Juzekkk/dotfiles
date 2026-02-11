--------------------------------------------------------------------------------
-- 1. LSP SERVER CONFIGURATION
--------------------------------------------------------------------------------
-- Configure the 'lua_ls' (Lua Language Server).
-- This sets specific options for working within Neovim.
vim.lsp.config["lua_ls"] = {
  settings = {
    Lua = {
      diagnostics = {
          -- Tell the language server that 'vim' is a global variable.
          -- Without this, you get constant "Undefined global 'vim'" warnings.
          globals = {'vim'},
      },
      -- Disable sending telemetry data to the server developers.
      telemetry = { enable = false },
      -- Enable inlay hints (e.g., showing parameter names in function calls).
      hint = { enable = true },
    },
  },
}

--------------------------------------------------------------------------------
-- 2. SNIPPETS
--------------------------------------------------------------------------------
-- These snippets use the custom `vim.snippet.add` helper defined in `init.lua`.
-- Syntax: ${1:placeholder} defines a tab stop. $0 is the final cursor position.

-- Trigger: 'au' -> Autocommand Boilerplate
-- Quickly creates a Neovim autocommand structure.
vim.snippet.add("au", [[
vim.api.nvim_create_autocmd("${1:Event}", {
  callback = function(args)
    $0
  end
})
]], { ft = "lua" })

-- Trigger: 'cl' -> Class/Object Boilerplate
-- Creates a standard Lua "class" pattern using metatables.
-- This is useful for object-oriented programming in Lua.
-- $1 = Namespace, $2 = ClassName (mirrored in multiple places), $3 = Method name.
vim.snippet.add("cl", [[
---@class ${1:namespace}.${2:ClassName}
local $2 = {}

function $2.new()
  ---@class $1.$2
  local self = setmetatable({}, {__index = $2})
  return self
end

function $2:${3:some_method}()
  $4
end
]], { ft = "lua" })

-- Trigger: 'sa' -> Snippet Adder
-- Meta-snippet: A snippet to create MORE snippets!
-- Note the use of `[=[ ... ]=]` delimiters. This is Lua's raw string syntax.
-- We use it here to avoid conflicts because the snippet body itself contains `[[ ]]`.
vim.snippet.add("sa", [=[
vim.snippet.add("${1:trigger}", [[
${2:snippet}
]], {ft = "${3:filetype}"})
]=], { ft = "lua" })

-- Trigger: 'bp' -> Boilerplate for Buffers/Windows
-- Useful for plugin development.
-- Creates a new scratch buffer (false, true) and opens it in a split window.
vim.snippet.add("bp", [[
local api = vim.api
local buf = api.nvim_create_buf(false, true)
local win = api.nvim_open_win(buf, false, {split = "right"})
]], { ft = "lua" })

-- Trigger: 'k' -> Keymap
-- Quickly generate a key binding statement.
vim.snippet.add("k", [[
vim.keymap.set("${1:mode}", "${2:key}", ${3:action})
]], { ft = "lua" })

--------------------------------------------------------------------------------
-- 3. SPECIFIC LANGUAGE OPTIONS (FTPLUGIN)
--------------------------------------------------------------------------------
-- This function runs automatically whenever a Lua file is opened.
vim.ftplugin.lua = function()
  -- VISUAL mode mapping:
  -- Pressing 'r' (run) while text is selected executes that selection as Lua code.
  vim.keymap.set("v", "r", ":'<,'>lua<CR>", { buffer = 0, silent = true })

  -- NORMAL mode mapping:
  -- Pressing 'R' (Reload) sources the entire current file.
  -- This is great for live-reloading your Neovim config changes immediately.
  vim.keymap.set("n", "R", ":source %<CR>", { buffer = 0, silent = true })
end
