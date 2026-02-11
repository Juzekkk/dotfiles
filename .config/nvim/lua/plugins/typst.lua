return {
  -- 1. Syntax Highlighting (Treesitter)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "typst" })
      end
    end,
  },

  -- 2. Ensure the tinymist binary is installed via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "tinymist" })
    end,
  },

  -- 3. Configure the Tinymist LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tinymist = {
          single_file_support = true,
          root_dir = function()
            return vim.fn.getcwd()
          end,
          settings = {
            exportPdf = "onType", -- Export PDF on type (options: "onType", "onSave", "never")
            outputPath = "$root/target/$dir/$name", -- output to target directory
            formatterMode = "typstyle", -- Use 'typstyle' or 'typstfmt'
          },
        },
      },
    },
  },

  -- 4. Add a previewer
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    build = function() require("typst-preview").update() end,
    opts = {
        open_cmd = "firefox -P typst-preview -new-window %s"
    },
    keys = {
      { "<leader>tp", "<cmd>TypstPreview<cr>", desc = "Start Typst Preview" },
    },
  },
}
