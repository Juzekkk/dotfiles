return {
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
