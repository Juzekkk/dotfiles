return {
  -- 1. nvim-dap: The core Debug Adapter Protocol client
  -- This allows Neovim to communicate with debuggers (for Go, Python, Lua, etc.)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "jbyuki/one-small-step-for-vimkind", -- A specific adapter for debugging Neovim Lua configurations
    },
    lazy = true,
    config = function()
      require("dap")
      -- Define custom icons (signs) for the gutter/sidebar to show breakpoint status
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "red" })          -- Standard breakpoint
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "blue" })  -- Conditional breakpoint (e.g. break if x > 5)
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "orange" }) -- Breakpoint that failed to attach or is invalid
      vim.fn.sign_define("DapStopped", { text = "󰁕", texthl = "green" })           -- The line where execution is currently paused
    end,
  },
  -- 2. debugmaster.nvim: A helper plugin to manage debug UI layouts
  {
    "miroshQa/debugmaster.nvim",
    config = function()
      local dm = require("debugmaster")
      -- Set a keybinding (<leader> + d) to toggle the debug interface/layout on and off
      vim.keymap.set({ "n", "v" }, "<leader>d", dm.mode.toggle, {
        nowait = true,
        desc = "Debug mode toggle"
      })
      -- Enable integration with the Lua debugger (OSV / one-small-step) defined in the first block
      dm.plugins.osv_integration.enabled = true
    end
  }
}
