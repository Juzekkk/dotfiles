return {
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    config = function()
      -- Override F5 only for Rust buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(ev)
          vim.keymap.set("n", "<F6>", "<cmd>RustLsp debuggables<CR>", {
            buffer = ev.buf,
            desc = "Rust debuggables (build + debug)",
          })
        end,
      })
    end,
  },
}
