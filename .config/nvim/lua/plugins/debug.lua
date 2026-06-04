return {
    {
        "mfussenegger/nvim-dap",

        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- UI
            dapui.setup()

            require("nvim-dap-virtual-text").setup()

            -- automatyczne otwieranie UI
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end

            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end

            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            -- CodeLLDB
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "codelldb",
                    args = { "--port", "${port}" },
                },
            }

            -- Rust
            dap.configurations.rust = {
                {
                    name = "Launch executable",
                    type = "codelldb",
                    request = "launch",

                    program = function()
                        return vim.fn.input(
                            "Executable: ",
                            vim.fn.getcwd() .. "/target/debug/",
                            "file"
                        )
                    end,

                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }

            -- keymapy
            vim.keymap.set("n", "<F5>", dap.continue)
            vim.keymap.set("n", "<F10>", dap.step_over)
            vim.keymap.set("n", "<F11>", dap.step_into)
            vim.keymap.set("n", "<F12>", dap.step_out)

            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>du", dapui.toggle)
            vim.keymap.set("n", "<leader>dr", dap.repl.open)
        end,
    },
}
