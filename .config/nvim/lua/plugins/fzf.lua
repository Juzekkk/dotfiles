return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",

        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },

        "jvgrootveld/telescope-zoxide",
    },

    keys = {
        { "<leader>f", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find files" },
        { "<leader>'", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
        { "<leader>k", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
        { "<leader>.", "<cmd>Telescope oldfiles<cr>", desc = "Old files" },
        { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>z", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide" },

        -- git
        { "<leader>sc", "<cmd>Telescope git_bcommits<cr>", desc = "Buffer commits" },
        { "<leader>sb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
        { "<leader>sC", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
    },

    vim.keymap.set("n", "<leader>/", function()
      require("telescope.builtin").live_grep({
        additional_args = function()
          return {
            "--hidden",
            "--no-ignore",
            "--glob",
            "!.git/*",
            "--glob",
            "!.config/*",
          }
        end,
      })
    end, { desc = "Live grep (with .config)" }),

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                layout_strategy = "horizontal",

                layout_config = {
                    width = 0.8,
                    height = 0.8,
                    preview_width = 0.5,
                },

                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<C-d>"] = actions.preview_scrolling_down,
                        ["<C-u>"] = actions.preview_scrolling_up,
                    },
                },
            },

            pickers = {
                find_files = {
                    hidden = true,
                },
            },
        })

        telescope.load_extension("fzf")
        telescope.load_extension("zoxide")
    end,
}
