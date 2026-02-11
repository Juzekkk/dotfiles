-- Calculate the path to where Mason installs binaries (usually ~/.local/share/nvim/mason/bin)
local mason_bin = vim.fs.joinpath(vim.fn.stdpath('data'), "mason/bin")

---Helper function to get the full path of a tool installed via Mason.
---Example: vim.get_mason_bin("python-debug-adapter")
---@param name string The name of the binary
---@return string The full path
vim.get_mason_bin = function(name)
  return vim.fs.joinpath(mason_bin, name)
end

---Wrapper to add VS Code style snippets using the LuaSnip plugin.
---This allows you to define snippets programmatically in your language files.
---@param trig string The trigger text
---@param body string The snippet body (supports VS Code syntax like $1, $0)
---@param opts {ft: string} Options table, specifically the filetype
vim.snippet.add = function(trig, body, opts)
  local ls = require("luasnip")
  -- Parse the string into a snippet object and add it to LuaSnip
  ls.add_snippets(opts.ft, { ls.parser.parse_snippet(trig, body) })
end

-- Make 'dap' globally accessible via vim.dap so you don't have to require it everywhere
vim.dap = require("dap")
vim.dap.utils = require("dap.utils")

-- Create a helper function to prompt the user for arguments when starting a debug session.
-- It splits the input string by spaces to pass as an array to the debugger.
vim.dap.utils.query_args = function()
  return vim.split(vim.fn.input('Program arguments: '), " +")
end

-- INITIALIZE CUSTOM FILETYPE PLUGIN TABLE
-- This table will hold setup functions for different languages.
-- Structure: { ["python"] = func(), ["rust"] = func() }
---@type table<string, fun()>
vim.ftplugin = {}

-- Find all lua files inside the "lua/languages/" directory (e.g., python.lua, rust.lua)
local files = vim.api.nvim_get_runtime_file("lua/languages/*.lua", true)

for _, path in ipairs(files) do
  -- Load every file found EXCEPT this current file (init.lua) to avoid infinite loops
  if not vim.endswith(path, "init.lua") then
    -- loadfile compiles the file, () executes it.
    -- These files are expected to add entries to the 'vim.ftplugin' table defined above.
    loadfile(path)()
  end
end

-- Iterate over the table populated by the files loaded in step 5.
-- Create an autocommand for every language found.
for ft, callback in pairs(vim.ftplugin) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,      -- When the FileType matches the key (e.g., "python")
    callback = callback -- Run the specific configuration function
  })
end
