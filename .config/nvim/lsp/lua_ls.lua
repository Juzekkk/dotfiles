--------------------------------------------------------------------------------
-- lua-language-server
--------------------------------------------------------------------------------
-- Neovim reads this file on its own because it sits in lsp/ on the
-- runtimepath. Turned on in lua/lsp.lua via vim.lsp.enable({ "lua_ls", ... }).
--
-- Install the server:
--   brew install lua-language-server
--   pacman -S lua-language-server
--   apt install lua-language-server
--------------------------------------------------------------------------------
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    "stylua.toml",
    ".stylua.toml",
    "selene.toml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      -- lazydev adds Neovim API and plugin paths as you use them. Without it
      -- the server would index all of ~/.local/share/nvim.
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true, arrayIndex = "Disable" },
      -- stylua handles formatting through conform
      format = { enable = false },
    },
  },
}
