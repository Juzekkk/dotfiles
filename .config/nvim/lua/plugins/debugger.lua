return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "jbyuki/one-small-step-for-vimkind",
    },
    keys = {
      { "<F5>",  function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "DAP Toggle Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP REPL" },
    },
    config = function()
      local dap = require("dap")
      dap.defaults.fallback.terminal_win_cmd = "belowright 15split new"

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "󰁕", texthl = "DiagnosticOk" })
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.33 },
              { id = "stacks", size = 0.33 },
              { id = "watches", size = 0.17 },
              { id = "breakpoints", size = 0.17 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
        floating = {
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
      })

      -- Open UI on start
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      -- IMPORTANT: do NOT auto-close on exit → keeps console open
      -- dap.listeners.before.event_terminated["dapui_config"] = function()
      --   dapui.close()
      -- end
      -- dap.listeners.before.event_exited["dapui_config"] = function()
      --   dapui.close()
      -- end

      vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP UI Toggle" })
    end,
  },
}
