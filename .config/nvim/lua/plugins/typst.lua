return {
  -- 1. Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    -- We use a function to safely append to the list without overwriting it
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "typst" })
    end,
  },

  -- 2. Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "tinymist" })
    end,
  },

  -- 3. LSP Config
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- You can put the specific settings here
        tinymist = {
          single_file_support = true,
          root_dir = function() return vim.fn.getcwd() end,
          settings = {
            exportPdf = "onType",
            outputPath = "$root/target/$dir/$name",
            formatterMode = "typstyle",
          },
        },
      },
    },
  },

  -- 4. Previewer
  {
      "chomosuke/typst-preview.nvim",
      ft = "typst",
      version = "1.*",
      build = function() require("typst-preview").update() end,
      opts = {
          open_cmd = "firefox -P typst-preview -new-window %s"
      },
      init = function ()
          vim.api.nvim_create_autocmd("FileType", {
              pattern = "typst",
              desc = "Typst Preview Keymap",
              callback = function(event)
                  vim.keymap.set("n", "<leader>p", "<cmd>TypstPreview<cr>", {
                      desc = "Start Typst Preview",
                      buffer = event.buf,
                      silent = true
                  })
              end,
          })
      end,
  },
}
