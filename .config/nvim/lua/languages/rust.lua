-- rustaceanvim config (optional, but keeps defaults explicit)
vim.g.rustaceanvim = {
  dap = {
    autoload_configurations = true,
  },
}

-- keep your custom single-file config available as a DAP entry
local dap = require("dap")

dap.configurations.rust = dap.configurations.rust or {}

table.insert(dap.configurations.rust, {
  name = "🧪 Debug Single File (rustc)",
  type = "codelldb",
  request = "launch",
  program = function()
    local file = vim.fn.expand("%:p")
    local outfile = vim.fn.tempname()
    local cmd = string.format("rustc -g %s -o %s", vim.fn.shellescape(file), vim.fn.shellescape(outfile))
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
      error("rustc failed:\n" .. result)
    end
    return outfile
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
  args = {},
  runInTerminal = true,
})
