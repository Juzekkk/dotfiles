--------------------------------------------------------------------------------
-- PLUGINS — vim.pack (built in, Neovim 0.12+)
--------------------------------------------------------------------------------
-- The complete inventory lives here. vim.pack clones anything missing at
-- startup and adds it to the runtimepath, so require("plugin") works
-- immediately after add().
--
-- Versions are pinned in ~/.config/nvim/nvim-pack-lock.json. That file is
-- generated for you; commit it.
--
-- Day to day:
--   :lua vim.pack.update()               -- update everything, shows a diff first
--   :lua vim.pack.update({ "fzf-lua" })  -- update one
--   :lua vim.pack.del({ "fzf-lua" })     -- delete from disk (remove from the list below first)
--   :lua =vim.pack.get()                 -- what is installed
--------------------------------------------------------------------------------

local function gh(repo, opts)
  return vim.tbl_extend("force", { src = "https://github.com/" .. repo }, opts or {})
end

vim.pack.add({
  ---------------------------------------------------------------------------
  -- Appearance
  ---------------------------------------------------------------------------
  gh("sainnhe/everforest"),
  gh("nvim-lualine/lualine.nvim"),
  gh("folke/which-key.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  -- mini.icons impersonates nvim-web-devicons (see ui.lua), so lualine,
  -- fzf-lua and nvim-tree all get icons from one plugin instead of two.
  gh("echasnovski/mini.icons"),

  ---------------------------------------------------------------------------
  -- Editing
  ---------------------------------------------------------------------------
  -- NOTE: branch "main" is a from-scratch rewrite. The nvim-treesitter.configs
  -- module no longer exists. Requires tree-sitter-cli on PATH.
  gh("nvim-treesitter/nvim-treesitter", { version = "main" }),
  gh("ibhagwan/fzf-lua"),
  gh("nvim-tree/nvim-tree.lua"),
  gh("stevearc/conform.nvim"),
  gh("saghen/blink.cmp", { version = vim.version.range("1.*") }),

  ---------------------------------------------------------------------------
  -- LSP
  ---------------------------------------------------------------------------
  -- Servers are configured natively in ~/.config/nvim/lsp/*.lua.
  -- nvim-lspconfig is not needed.
  gh("folke/lazydev.nvim"), -- vim.* types while editing this config
  gh("mrcjkb/rustaceanvim"), -- owns rust-analyzer; do not add lsp/rust_analyzer.lua

  ---------------------------------------------------------------------------
  -- Debugging
  ---------------------------------------------------------------------------
  gh("mfussenegger/nvim-dap"),
  gh("igorlfs/nvim-dap-view", { version = vim.version.range("1.*") }),
  gh("mfussenegger/nvim-dap-python"), -- finds the venv, can debug a single test

  ---------------------------------------------------------------------------
  -- Markdown
  ---------------------------------------------------------------------------
  gh("MeanderingProgrammer/render-markdown.nvim"),
})

--------------------------------------------------------------------------------
-- Post install / update hooks
--------------------------------------------------------------------------------
-- The equivalent of lazy.nvim's `build = ...`. PackChanged fires after any
-- on-disk change (install / update / delete).
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-build", { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind ~= "delete" then
      vim.schedule(function()
        vim.cmd("TSUpdate")
      end)
    end
  end,
})
