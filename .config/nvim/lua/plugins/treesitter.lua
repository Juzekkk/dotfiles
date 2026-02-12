return {
  -- 1. nvim-treesitter: The parsing engine
  -- This plugin parses code into an abstract syntax tree (AST) to provide 
  -- better highlighting, indentation, and code manipulation.
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" }, -- Load when opening a file
    build = ":TSUpdate", -- Command to run after installation to update parsers
    main = "nvim-treesitter.config", -- Entry point for configuration
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Adds support for "text objects" (functions, classes, etc.)
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.config").setup {
        auto_install = true, -- Automatically install missing parsers for filetypes you open
        highlight = {
          enable = true, -- Enable the advanced Treesitter-based syntax highlighting
        },
        -- Textobjects configuration: Allows you to treat code structures like "words" or "paragraphs"
        textobjects = {
          -- Selection: "af" selects a whole function, "if" selects just the body, etc.
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to the textobj if not currently under cursor
            keymaps = {
              ["af"] = "@function.outer", -- Select Around Function
              ["if"] = "@function.inner", -- Select Inner Function
              ["ac"] = "@class.outer",    -- Select Around Class
              ["ic"] = {
                  query = "@class.inner",
                  desc = "Select inner part of a class region",
              },
              ["as"] = {
                  query = "@local.scope",
                  query_group = "locals",
                  desc = "Select language scope", -- Useful for selecting current scope
              },
            },
            include_surrounding_whitespace = true,
          },
          -- Navigation: Jump instantly to the next/prev function or class
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
          -- Swapping: Reorder arguments or parameters effortlessly
          -- Example: Swap the current argument with the next one using "}"
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

  -- 2. nvim-ts-autotag
  -- Automatically closes HTML/XML/JSX tags (e.g., typing <div> automatically adds </div>)
  {
    "windwp/nvim-ts-autotag",
    ft = { "js", "html", "javascriptreact", "ts", "jsx", "tsx" }, -- Only load for web-related files
    opts = {},
  },

  -- 3. TreeSJ (Treesitter Split/Join)
  -- Allows you to toggle code blocks between single-line and multi-line formats.
  -- Example: Turn a one-line object `{ a = 1, b = 2 }` into a multi-line struct.
  {
    "Wansmer/treesj",
    keys = {
      {
          "gs", -- Mnemonic: "Go Split" or "Go Switch"
          function() require("treesj").toggle() end,
          mode = "n",
      },
      {
          "gS", -- Recursive split (expands nested objects too)
          function() require("treesj").toggle {split = {recursive = true}} end,
          mode = "n",
      }
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("treesj").setup {
        max_join_length = 1000000, -- Allow joining very long lines
        use_default_keymaps = false,
      }
    end,
  }
}
