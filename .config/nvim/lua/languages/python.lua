--------------------------------------------------------------------------------
-- 1. ADAPTER DEFINITION
--------------------------------------------------------------------------------
-- Documentation: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python

-- Configure the 'python' debug adapter.
vim.dap.adapters.python = {
  type = 'executable',
  -- Helper function from init.lua gets the path to 'debugpy-adapter' installed by Mason.
  command = vim.get_mason_bin("debugpy-adapter"),
  options = {
    -- Hints to nvim-dap that this adapter handles python files.
    source_filetype = 'python',
  },
}

--------------------------------------------------------------------------------
-- 2. LAUNCH CONFIGURATIONS
--------------------------------------------------------------------------------
vim.dap.configurations.python = {
  {
    -- The type MUST match the adapter name defined above ('python').
    type = 'python',
    request = 'launch',
    name = "🐍 Launch Current File", -- Descriptive name for the DAP menu

    -- "${file}" is a special variable that nvim-dap expands to the
    -- path of the file currently open in the editor.
    program = "${file}",

    -- 'integratedTerminal' runs the output inside a Neovim terminal split.
    -- Alternative: 'internalConsole' (DAP REPL only) or 'externalTerminal'.
    console = "integratedTerminal",
  },
}
