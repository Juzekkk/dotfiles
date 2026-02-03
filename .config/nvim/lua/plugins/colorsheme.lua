return {
  {
    "sainnhe/everforest",
    lazy = false,      -- load at startup
    priority = 1000,   -- load before other UI plugins
    config = function()
      -- Must be set BEFORE :colorscheme
      vim.g.everforest_background = "hard" -- "soft" | "medium" | "hard"
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_disable_italic_comment = 0
      vim.g.everforest_transparent_background = 0
      vim.g.everforest_ui_contrast = "low" -- "low" | "high"
      vim.g.everforest_better_performance = 1

      vim.cmd.colorscheme("everforest")
    end,
  },
}
