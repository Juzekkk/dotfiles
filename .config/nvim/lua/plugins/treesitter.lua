return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    main = "nvim-treesitter.config", -- CHANGED: configs -> config
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.config").setup { -- CHANGED: configs -> config
        auto_install = true,
        highlight = {
          enable = true,
        },
        -- Configure textobjects here inside the main setup
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = {
                  query = "@class.inner",
                  desc = "Select inner part of a class region",
              },
              ["as"] = {
                  query = "@local.scope",
                  query_group = "locals",
                  desc = "Select language scope",
              },
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
          -- Use the built-in swap module instead of manual requires
          swap = {
            enable = true,
            swap_next = {
              ["}"] = "@parameter.inner",
            },
            swap_previous = {
              ["{"] = "@parameter.inner",
            },
          },
        },
      }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "js", "html", "javascriptreact", "ts", "jsx", "tsx" },
    opts = {},
  },
  {
    "Wansmer/treesj",
    keys = {
      {
          "gs",
          function() require("treesj").toggle() end,
          mode = "n",
      },
      {
          "gS",
          function() require("treesj").toggle {split = {recursive = true}} end,
          mode = "n",
      }
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("treesj").setup {
        max_join_length = 1000000,
        use_default_keymaps = false,
      }
    end,
  }
}
