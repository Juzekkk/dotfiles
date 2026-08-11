--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------
-- Server configs live in ~/.config/nvim/lsp/<name>.lua. Neovim discovers them
-- on the runtimepath by itself, so nvim-lspconfig is not involved.
--
-- Troubleshooting:
--   :checkhealth vim.lsp
--   :lsp                 -- client status
--   :lsp restart <name>
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------
-- Sign text is escape encoded for the same reason as the DAP signs: a stripped
-- glyph leaves an empty string and the sign disappears without any error.
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = "\u{25CF}" }, -- ●
  -- virtual_lines shows the full message under the cursor. Off by default,
  -- because together with virtual_text it gets crowded. Toggle: <leader>tv
  virtual_lines = false,
  float = { border = "rounded", source = "if_many", max_width = 80 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{2716}", -- ✖
      [vim.diagnostic.severity.WARN] = "\u{25B2}", -- ▲
      [vim.diagnostic.severity.INFO] = "\u{25CF}", -- ●
      [vim.diagnostic.severity.HINT] = "\u{25CB}", -- ○
    },
  },
})

--------------------------------------------------------------------------------
-- Capabilities — once, for every server
--------------------------------------------------------------------------------
-- blink.cmp registers itself through its own plugin/ file, but vim.pack only
-- sources plugin/ directories after init.lua has finished. With `nvim file.py`
-- a server can start before that, and then it never learns about snippet or
-- resolve support. Setting it explicitly removes the race.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities({}, true),
})

--------------------------------------------------------------------------------
-- lazydev — vim.* and plugin types while editing this config
--------------------------------------------------------------------------------
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

--------------------------------------------------------------------------------
-- rustaceanvim
--------------------------------------------------------------------------------
-- Set before any .rs buffer opens. rustaceanvim starts rust-analyzer itself,
-- which is why there is no lsp/rust_analyzer.lua and why you must not add it
-- to vim.lsp.enable() below. Two clients on one buffer breaks hover and
-- code actions in confusing ways.
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        check = { command = "clippy", extraArgs = { "--no-deps" } },
        cargo = { allFeatures = true, buildScripts = { enable = true } },
        procMacro = { enable = true },
        inlayHints = {
          lifetimeElisionHints = { enable = "skip_trivial" },
          closureReturnTypeHints = { enable = "with_block" },
        },
      },
    },
  },
  tools = {
    -- rustaceanvim replaces Neovim's hover handler with its own, and that
    -- handler does not read vim.o.winborder. Without this block the Rust
    -- hover window has no rounded border and no size cap, so a big type
    -- signature covers the whole screen.
    -- Accepts anything vim.lsp.util.open_floating_preview() accepts.
    float_win_config = {
      border = "rounded",
      max_width = 80,
      max_height = 16,
      -- Without this, capping the width clips long lines instead of folding
      -- them, so the end of every sentence is lost off the right edge.
      wrap = true,
      auto_focus = false, -- press K twice to enter the window
    },
  },
  dap = {
    -- Finds codelldb on PATH and wires it into :RustLsp debuggables
    autoload_configurations = true,
  },
}

--------------------------------------------------------------------------------
-- Enable servers
--------------------------------------------------------------------------------
vim.lsp.enable({
  "lua_ls",
  "basedpyright",
  "ruff",
})

--------------------------------------------------------------------------------
-- What happens once a server attaches to a buffer
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
    local buf = args.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
    end

    -- Navigation. Neovim 0.11+ already ships grr/gri/grn/gra, but these are
    -- the ones your fingers know from coc.
    map("n", "gd", vim.lsp.buf.definition, "Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Declaration")
    map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
    map("n", "gi", vim.lsp.buf.implementation, "Implementation")
    map("n", "gr", require("fzf-lua").lsp_references, "References")
    map("n", "gO", require("fzf-lua").lsp_document_symbols, "Document symbols")

    -- Neovim maps K to hover by default, but the default has no size limit,
    -- so a long docstring takes over the screen. Ours is capped.
    -- Skipped for Rust: after/ftplugin/rust.lua binds K to `RustLsp hover
    -- actions`, and LspAttach and ftplugin can fire in either order.
    if client.name ~= "rust-analyzer" then
      map("n", "K", function()
        vim.lsp.buf.hover({ border = "rounded", max_width = 80, max_height = 16, wrap = true })
      end, "Hover documentation")
    end

    -- Actions (the F2 / Ctrl+. equivalents from VS Code)
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<F2>", vim.lsp.buf.rename, "Rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cf", function()
      require("conform").format({ async = true, lsp_format = "fallback" })
    end, "Format")

    -- Inlay hints (you had these on in coc-settings; these are the native ones)
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end

    -- Highlight other occurrences of the symbol under the cursor.
    -- The equivalent of your CursorHold -> CocActionAsync("highlight"), but
    -- scoped to the buffer and cleaned up when the server detaches.
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("lsp-highlight-" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = hl_group,
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = hl_group,
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = hl_group,
        buffer = buf,
        callback = function()
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = hl_group, buffer = buf })
        end,
      })
    end

    -- LSP folding when the server supports it. It catches comments and
    -- regions that treesitter does not see.
    if client:supports_method("textDocument/foldingRange") then
      vim.wo[vim.api.nvim_get_current_win()][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    -- ruff and basedpyright share Python buffers: ruff does lint and format,
    -- basedpyright does types and hover. Without this you get two hovers.
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})
