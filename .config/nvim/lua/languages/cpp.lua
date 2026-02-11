--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------

-- Custom function to ask for the executable path.
-- BENEFIT: This uses the native Vim command line with Tab-completion.
-- You can type "bu" <Tab> to get "build/", then "m" <Tab> to get "main".
-- It avoids generating a massive list of 10,000 files to scroll through.
local function get_binary_path()
  local path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  -- If user presses Enter on empty line or Ctrl-C, abort the debug start
  return path ~= "" and path or vim.dap.ABORT
end

--------------------------------------------------------------------------------
-- ADAPTER DEFINITIONS
-- These tell nvim-dap "how" to talk to the debugger executable.
--------------------------------------------------------------------------------

-- 1. cppdbg (OpenDebugAD7)
-- This is the Microsoft debugger extracted from VS Code.
-- BEST FOR: GDB compatibility, complex C++ projects, or using 'rr'.
vim.dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = vim.get_mason_bin("OpenDebugAD7"), -- Helper from init.lua
}

-- 2. codelldb
-- A standalone LLDB adapter.
-- BEST FOR: Modern C++, Rust, and generally faster performance on macOS/Linux.
vim.dap.adapters.codelldb = {
  type = "executable",
  command = vim.get_mason_bin("codelldb"),
}

--------------------------------------------------------------------------------
-- DEBUG CONFIGURATIONS
-- These are the options that appear in the menu when you press F5 (Continue).
--------------------------------------------------------------------------------

vim.dap.configurations.cpp = {

  -- CONFIG 1: Standard Debugging (CodeLLDB)
  -- This is your "Default" go-to option. It uses the modern CodeLLDB adapter.
  {
    name = "Debug Executable (CodeLLDB)",
    type = "codelldb",       -- Matches adapter defined above
    request = "launch",      -- We are starting a new process, not attaching
    program = get_binary_path, -- Calls our helper function
    cwd = '${workspaceFolder}', -- Working directory is project root
    stopOnEntry = false,     -- Don't pause immediately, run until breakpoint/crash
  },

  -- CONFIG 2: Standard Debugging (OpenDebugAD7/Microsoft)
  -- Use this if CodeLLDB fails or if you prefer GDB-style behavior.
  -- Includes a fix for the "SIGWINCH" signal which pauses execution on window resize.
  {
    name = "Debug Executable (Microsoft/GDB Engine)",
    type = 'lldb',           -- Note: Some setups map 'lldb' to cpptools internally
    request = 'launch',
    program = get_binary_path,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    runInTerminal = true,    -- Opens an integrated terminal for Input/Output
    initCommands = {
      -- IGNORE WINDOW RESIZE SIGNALS
      -- Without this, resizing a vim split will pause your program.
      "process handle SIGWINCH -p true -s false -n false"
    }
  },

  -- CONFIG 3: Process Attachment
  -- Use this to debug a program that is ALREADY running (e.g., a background server).
  -- LINUX NOTE: You might need to run `echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope`
  -- to allow attaching to processes.
  {
    name = "Attach to Running Process (Pick PID)",
    type = 'lldb',
    request = 'attach',
    pid = vim.dap.utils.pick_process, -- Shows a searchable list of running processes
    args = {},
  },

  -- CONFIG 4: Record and Replay (rr)
  -- This is for "Time Travel Debugging".
  -- PREREQUISITE: You must have 'rr' installed on your OS and the recording started externally.
  -- (e.g., run `rr replay -s 50505` in a separate terminal first).
  {
    name = "Time Travel Debug (rr) - Connect to Server",
    type = "cppdbg",         -- Must use Microsoft adapter for GDB/MI support
    request = "launch",
    program = get_binary_path, -- You still need to point to the binary symbols
    miDebuggerServerAddress = "127.0.0.1:50505", -- Connects to the waiting 'rr' session
    stopAtEntry = true,      -- Usually good to stop at start for rr
    cwd = vim.fn.getcwd,
    externalConsole = true,  -- Opens external terminal window
    MIMode = "gdb",
  },
}

-- Apply the same configurations to C files
vim.dap.configurations.c = vim.dap.configurations.cpp
