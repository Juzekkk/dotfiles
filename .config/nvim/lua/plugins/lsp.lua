return {
    {
        "williamboman/mason.nvim",
        opts = {
            ui = {
                backdrop = 100,
            },
        },
    },
    { "williamboman/mason-lspconfig.nvim", },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        ensure_installed = {
            -- cpp / c --
            "codelldb",
            "cpptools",
            -- python --
            "debugpy",
            "python-lsp-server",
            "ruff",
            -- lua --
            "lua-language-server",
            "luacheck",
        },
        config = function()
            vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Lsp restart" })
            vim.keymap.set("n", "<leader>lm", "<cmd>Mason<CR>", { desc = "Mason" })
            require("mason").setup()
            require("mason-lspconfig").setup()
        end,
    },
    {
        "j-hui/fidget.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            notification = {
                window = {
                    winblend = 0,
                },
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
