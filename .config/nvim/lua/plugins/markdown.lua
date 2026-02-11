return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && npm install",
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Start Markdown Preview" },
        },
        init = function()
            vim.cmd([[
                function OpenMarkdownPreview (url)
                    " shellescape() protects against URLs with special chars
                    " The '&' allows Neovim to keep running the server
                    execute "silent ! firefox -P typst-preview -new-window " . shellescape(a:url) . " &"
                endfunction
            ]])
            vim.g.mkdp_browserfunc = 'OpenMarkdownPreview'
        end,
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "marksman" })
        end,
    },
    {
        "Myzel394/easytables.nvim",
        ft = "markdown",
        keys = {
            { "<Leader>mtn", ":EasyTablesCreateNew ", desc = "Create New Table (e.g. 5x4)" },
            { "<Leader>mti", "<cmd>EasyTablesImportThisTable<CR>", desc = "Import/Edit Current Table" },
            { "<Leader>mte", ":ExportTable<CR>", desc = "Export Current Table" },
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
