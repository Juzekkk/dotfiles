return {
    -- coc.nvim - kompletna wymiana za Mason + nvim-lspconfig + nvim-cmp
    {
        "neoclide/coc.nvim",
        branch = "release",
        lazy = false,
        event = { "BufReadPost", "BufNewFile" },
        build = "npm ci",
        init = function()
            vim.g.coc_global_extensions = {
                "coc-json",
                "coc-yaml",
                "coc-snippets",
                "coc-sh",
                "coc-marketplace",

                -- języki
                "coc-lua",
                "coc-typst",
                "coc-pyright",
                "coc-rust-analyzer",
                "coc-rls",
                "coc-markdownlint",
            }
        end,
        config = function()
            -- ── Completion behaviour ──────────────────────────────────────────
            -- Tab: jeśli menu widoczne → wybierz następny; jeśli snippet → skocz dalej; inaczej → Tab
            vim.keymap.set("i", "<TAB>", function()
                if vim.fn["coc#pum#visible"]() == 1 then
                    return vim.fn["coc#pum#next"](1)
                elseif vim.fn["coc#expandableOrJumpable"]() == 1 then
                    return "<Plug>(coc-snippets-expand-jump)"
                else
                    return "<TAB>"
                end
            end, { silent = true, expr = true, noremap = true })

            vim.keymap.set("i", "<S-TAB>", function()
                if vim.fn["coc#pum#visible"]() == 1 then
                    return vim.fn["coc#pum#prev"](1)
                else
                    return "<S-TAB>"
                end
            end, { silent = true, expr = true, noremap = true })

            -- Enter potwierdza wybrany element (lub zwykły Enter jeśli nic nie wybrano)
            vim.keymap.set("i", "<CR>", function()
                if vim.fn["coc#pum#visible"]() == 1 and vim.fn["coc#pum#info"]().index >= 0 then
                    return vim.fn["coc#pum#confirm"]()
                else
                    -- Autopairs-friendly: dodaj nową linię z właściwym wcięciem
                    return "<C-g>u<CR><c-r>=coc#on_enter()<CR>"
                end
            end, { silent = true, expr = true, noremap = true })

            -- Ctrl+Space: wymuś otwarcie menu
            vim.keymap.set("i", "<C-space>", "coc#refresh()", { silent = true, expr = true })

            -- Scroll dokumentacji w popup
            vim.keymap.set({ "i", "n" }, "<C-u>", function()
                if vim.fn["coc#float#has_scroll"]() == 1 then
                    return vim.fn["coc#float#scroll"](0)
                else return "<C-u>" end
            end, { silent = true, expr = true, nowait = true })

            vim.keymap.set({ "i", "n" }, "<C-d>", function()
                if vim.fn["coc#float#has_scroll"]() == 1 then
                    return vim.fn["coc#float#scroll"](1)
                else return "<C-d>" end
            end, { silent = true, expr = true, nowait = true })

            -- ── LSP Navigation ───────────────────────────────────────────────
            vim.keymap.set("n", "gd", "<Plug>(coc-definition)",       { silent = true })
            vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)",   { silent = true })
            vim.keymap.set("n", "gi", "<Plug>(coc-implementation)",    { silent = true })
            vim.keymap.set("n", "gr", "<Plug>(coc-references)",        { silent = true })
            vim.keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev)",   { silent = true })
            vim.keymap.set("n", "]d", "<Plug>(coc-diagnostic-next)",   { silent = true })

            -- ── Hover / Documentation ────────────────────────────────────────
            vim.keymap.set("n", "K", function()
                local ft = vim.bo.filetype
                if ft == "vim" or ft == "help" then
                    vim.cmd("h " .. vim.fn.expand("<cword>"))
                elseif vim.fn["coc#rpc#ready"]() == 1 then
                    vim.fn.CocActionAsync("doHover")
                else
                    vim.cmd("!" .. vim.o.keywordprg .. " " .. vim.fn.expand("<cword>"))
                end
            end, { silent = true })

            -- ── Code Actions ─────────────────────────────────────────────────
            vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)",               { silent = true })
            vim.keymap.set({ "n", "v" }, "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true })
            vim.keymap.set("n", "<leader>cf", "<Plug>(coc-fix-current)",           { silent = true })
            vim.keymap.set("n", "<leader>cl", "<Plug>(coc-codelens-action)",       { silent = true })

            -- ── Diagnostics list ─────────────────────────────────────────────
            vim.keymap.set("n", "<leader>ld", "<cmd>CocList diagnostics<cr>",  { silent = true, desc = "List diagnostics" })
            vim.keymap.set("n", "<leader>le", "<cmd>CocList extensions<cr>",   { silent = true, desc = "List extensions" })
            vim.keymap.set("n", "<leader>lc", "<cmd>CocList commands<cr>",     { silent = true, desc = "List commands" })

            -- Mason zastąpiony przez CocList / CocInstall
            vim.keymap.set("n", "<leader>lm", "<cmd>CocList extensions<cr>", { desc = "Coc extensions (zamiast Mason)" })
            vim.keymap.set("n", "<leader>lr", "<cmd>CocRestart<CR>",          { desc = "Coc restart" })

            -- ── Highlight symbol under cursor ─────────────────────────────────
            vim.api.nvim_create_autocmd("CursorHold", {
                callback = function() vim.fn.CocActionAsync("highlight") end,
            })

        end,
    },

    -- Autopairs - zostaje, ale bez integracji z cmp
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
            -- Coc obsługuje enter samodzielnie (patrz mapowanie <CR> wyżej),
            -- więc NIE podpinamy tutaj cmp_autopairs
        end,
    },

    -- Surround - bez zmian
    {
        "kylechui/nvim-surround",
        version = "^3.0.0",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },

    -- lazydev zostaje (daje typy dla vim.* w Lua)
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
