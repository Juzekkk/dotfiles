---@diagnostic disable: missing-fields
return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = { "Neotree" },
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle reveal<CR>", mode = "n", desc = "Toggle file tree" }
  },
  config = function()
    require("neo-tree").setup {
      popup_border_style = "rounded",
      filesystem = {
        shared_clipboard = true,
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
      },
      window = {
        position = "left",
      },
    }
  end,
}
