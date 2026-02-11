--------------------------------------------------------------------------------
-- UI HIGHLIGHTS
--------------------------------------------------------------------------------

-- Highlight text immediately after yanking (copying) it.
-- This gives visual feedback so you know exactly what region you copied.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    -- 'higroup' sets the color (usually a bright yellow/orange flash)
    -- 'timeout' is how long the flash lasts in milliseconds
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

--------------------------------------------------------------------------------
-- FILETYPE SPECIFIC BEHAVIORS
--------------------------------------------------------------------------------

-- Improve the experience in 'help' buffers.
-- Instead of typing ':q<enter>' to close help, just press 'q'.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"help", "man"}, -- Applied to Neovim help and Linux man pages
  callback = function()
    -- Map 'q' to the quit command, only for this specific buffer
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = 0 })
  end
})

-- Disable automatic comment insertion on new lines.
-- By default, if you are in a comment and press 'Enter' (r) or 'o' (o),
-- Vim continues the comment on the next line. This removes that behavior.
-- 'r' = Enter key, 'o' = 'o' or 'O' keys.
vim.cmd([[autocmd FileType * set formatoptions-=ro]])

--------------------------------------------------------------------------------
-- LSP (LANGUAGE SERVER) AUTOMATION
--------------------------------------------------------------------------------

-- This block runs every time an LSP attaches to a buffer (e.g., opening a Python file).
-- It sets up "Document Highlighting" (highlighting same variables under cursor).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    -- Get the client (language server) that just attached
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Check if this server actually supports highlighting (some don't)
    if client and client.server_capabilities.documentHighlightProvider then

      -- 1. When the cursor rests (holds) on a word...
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf, -- Only for this specific buffer
        callback = vim.lsp.buf.document_highlight, -- Highlight all instances of the word
      })

      -- 2. When the cursor moves away...
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references, -- Clear the highlights
      })

    end
  end,
})

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT
--------------------------------------------------------------------------------

-- Auto-resize splits when the terminal window is resized.
-- If you drag your terminal window to be larger/smaller, Neovim splits might
-- stay fixed size. This command forces them to be equal width/height again.
vim.api.nvim_create_autocmd('VimResized', {
  callback = function(ev)
    vim.cmd("wincmd =")
  end,
})
