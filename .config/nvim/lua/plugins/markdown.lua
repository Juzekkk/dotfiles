return {
    -- 1. Syntax Highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        -- We use a function to safely append to the list without overwriting it
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "marksman" })
        end,
    },
    -- 2. Preview
    {
        "iamcco/markdown-preview.nvim",
        -- Lazy load when these commands are called
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        -- Lazy load when opening a markdown file
        ft = { "markdown" },
        build = "cd app && npm install",
        init = function()
            -- 1. Browser Configuration (variables must be set before plugin loads)
            vim.cmd([[
            function! OpenMarkdownPreview (url)
            execute "silent ! firefox -P typst-preview -new-window " . shellescape(a:url) . " &"
            endfunction
            ]])
            vim.g.mkdp_browserfunc = 'OpenMarkdownPreview'
            -- Prevent the plugin from closing the preview when you switch buffers
            -- (Optional, but usually desired workflow)
            vim.g.mkdp_auto_close = 0

            -- 2. Define Keymap ONLY for Markdown Files
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                desc = "Markdown Preview Keymap",
                callback = function(event)
                    -- { buffer = event.buf } makes the mapping exist ONLY in this specific buffer
                    vim.keymap.set("n", "<leader>p", "<cmd>MarkdownPreview<cr>", {
                        desc = "Start Markdown Preview",
                        buffer = event.buf,
                        silent = true
                    })
                end,
            })
        end,
    },
    -- Easier Table Editing
    {
        "Myzel394/easytables.nvim",
        ft = "markdown",
        init = function()
            -- Define Keymap ONLY for Markdown Files
            vim.api.nvim_create_autocmd("FileType", {
                desc = "Markdown Preview Keymap",
                callback = function(event)
                    vim.keymap.set("n", "<Leader>tn", ":EasyTablesCreateNew ", {
                        desc = "Create New Table (e.g. 5x4)",
                    })
                    vim.keymap.set("n", "<Leader>ti", "<cmd>EasyTablesImportThisTable<cr>", {
                        desc = "Import/Edit Current Table",
                    })
                    vim.keymap.set("n", "<Leader>te", "<cmd>ExportTable<cr>", {
                        desc = "Export Current Table",
                    })
                end,
            })
        end,
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
