# Language Configuration Guide

This directory contains modular configuration files for specific programming languages.

## How it Works

The `init.lua` in this directory is the **Loader**. It performs the following steps:
1.  **Scans** this directory for all `*.lua` files.
2.  **Executes** them immediately (loading LSP, DAP, and Snippets).
3.  **Registers** the `vim.ftplugin` table values as Autocommands.

## How to Add a New Language

1.  Create a file named after the language (e.g., `rust.lua` or `go.lua`).
2.  Follow the template below to add features.

### Template
```lua
-- lua/languages/example.lua

-- 1. LSP Configuration
vim.lsp.config["example_server"] = {
  settings = { ... }
}

-- 2. Snippets
vim.snippet.add("trig", "snippet body", { ft = "example" })

-- 3. Debugger (DAP)
vim.dap.adapters.example = { ... }
vim.dap.configurations.example = { ... }

-- 4. Buffer Local Settings (Keymaps, Indent, etc.)
vim.ftplugin.example = function()
  vim.opt_local.expandtab = true
  vim.keymap.set("n", "<leader>r", "...", { buffer = 0 })
end
