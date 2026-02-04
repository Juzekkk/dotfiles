return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons", -- or "echasnovski/mini.icons"
    },
    ft = { "markdown", "Avante" },
    opts = {
        link = {
            enabled = false -- don't show icon
        },
        pipe_table = {
            present = 'round',
            border_virtual = true,
        },
      -- You can customize your config here.
    },
  },
  {
      "Myzel394/easytables.nvim",
      ft = "markdown",
      -- 'keys' belongs to lazy.nvim, not inside setup()
      keys = {
          { "<Leader>tn", ":EasyTablesCreateNew ", desc = "Create New Table (e.g. 5x4)" },
          { "<Leader>ti", "<cmd>EasyTablesImportThisTable<CR>", desc = "Import/Edit Current Table" },
          { "<Leader>t4", "<cmd>EasyTablesCreateNew 4<CR>", desc = "Create 4x4 Table" },
      },
      config = function()
          require("easytables").setup({
              -- 'set_mappings' belongs directly in setup(), not inside a nested 'opts'
              set_mappings = function(buf)
                  local map = function(lhs, rhs, desc)
                      vim.api.nvim_buf_set_keymap(buf, "n", lhs, rhs, {
                          nowait = true,
                          silent = true,
                          desc = "EasyTables: " .. desc,
                      })
                  end

                  -- HJKL Navigation
                  map("h", ":JumpLeft<CR>", "Jump Left")
                  map("l", ":JumpRight<CR>", "Jump Right")
                  map("k", ":JumpUp<CR>", "Jump Up")
                  map("j", ":JumpDown<CR>", "Jump Down")

                  -- Shift + HJKL for Swapping Cells
                  map("H", ":SwapWithLeftCell<CR>", "Swap Left")
                  map("L", ":SwapWithRightCell<CR>", "Swap Right")
                  map("K", ":SwapWithUpperCell<CR>", "Swap Up")
                  map("J", ":SwapWithLowerCell<CR>", "Swap Down")

                  -- Ctrl + HJKL for Swapping Rows/Columns
                  map("<C-h>", ":SwapWithLeftColumn<CR>", "Swap Col Left")
                  map("<C-l>", ":SwapWithRightColumn<CR>", "Swap Col Right")
                  map("<C-k>", ":SwapWithUpperRow<CR>", "Swap Row Up")
                  map("<C-j>", ":SwapWithLowerRow<CR>", "Swap Row Down")

                  -- Standard Tab navigation
                  map("<Tab>", ":JumpToNextCell<CR>", "Next Cell")
                  map("<S-Tab>", ":JumpToPreviousCell<CR>", "Prev Cell")
              end,
          })
      end,
  },
}
