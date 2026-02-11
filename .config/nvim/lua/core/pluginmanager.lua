--------------------------------------------------------------------------------
-- 1. BOOTSTRAP LAZY.NVIM
--------------------------------------------------------------------------------
-- Calculate the path where lazy.nvim should be installed.
-- Standard path: ~/.local/share/nvim/lazy/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if the directory exists. If NOT, we need to clone it.
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"

  -- Execute the git clone command
  local out = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none", -- Partial clone: downloads only recent history (faster)
      "--branch=stable",    -- Use the stable release, not the bleeding edge dev branch
      lazyrepo,
      lazypath,
  })

  -- Error Handling: If git failed (exit code != 0), stop everything.
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Add the newly cloned directory to the Runtime Path (RTP).
-- This allows us to run `require("lazy")` in the next step.
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- 2. CONFIGURE LAZY.NVIM
--------------------------------------------------------------------------------
require("lazy").setup({
  -- UI Customization for the Lazy window (:Lazy)
  ui = {
    backdrop = 100,    -- Darkness of the background blur (0-100)
    border = "rounded", -- Nice rounded corners for the floating window
  },

  -- PLUGIN SPECS (Where are your plugins defined?)
  spec = {
    -- This tells Lazy to import every lua file in the 'lua/plugins' folder.
    -- This is what allows you to have modular config files (e.g., lua/plugins/lsp.lua).
    {import = "plugins"},
  },

  -- Update Checker
  checker = {
    -- Automatically check for plugin updates, but don't nag me with popups.
    -- You can see updates available in the :Lazy menu.
    notify = false,
  },

  -- Hot Reloading
  change_detection = {
    enabled = true, -- Automatically reload config when you save a file
    notify = false  -- Don't show a notification every time I save a config file
  },

  -- Performance Optimizations
  performance = {
    rtp = {
      -- Disable built-in Vim plugins that we don't need or are replacing.
      -- Turning these off slightly improves startup time.
      disabled_plugins = {
        "matchit",      -- Enhanced % matching (often handled by treesitter)
        "matchparen",   -- Highlight matching parenthesis (often handled by treesitter)
        "netrwPlugin",  -- The default file explorer (replaced by neo-tree/nvim-tree)
        "gzip",         -- Editing .gz files
        "tarPlugin",    -- Editing .tar files
        "tohtml",       -- Convert code to HTML
        "tutor",        -- Vim Tutor
        "zipPlugin",    -- Editing .zip files
      },
    },
  },
})
