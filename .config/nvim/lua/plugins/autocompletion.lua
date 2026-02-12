-- Define a table of icons to visually represent different kinds of completion items
-- (e.g., variables, functions, classes) in the completion menu.
local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

return {
    -- 1. Configuration for nvim-cmp (The Autocompletion Engine)
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter", -- Load this plugin only when entering Insert mode to improve startup time
        dependencies = {
            "L3MON4D3/LuaSnip",        -- Snippet engine
            "saadparwaiz1/cmp_luasnip", -- Source for LuaSnip
            "hrsh7th/cmp-nvim-lsp",    -- Source for LSP completion
            "hrsh7th/cmp-path",        -- Source for filesystem paths
            "rcarriga/cmp-dap"         -- Source for Debug Adapter Protocol (DAP)
        },
        config = function()
            local cmp = require("cmp")
            local types = require('cmp.types')
            local luasnip = require("luasnip")
            local compare = cmp.config.compare

            -- Setup options for cmp
            local opts = {
                -- Condition to enable cmp:
                -- 1. Enabled in standard buffers (not prompt buffers)
                -- 2. OR enabled if we are currently in a DAP (debugger) session
                enabled = function()
                    return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt"
                    or require("cmp_dap").is_dap_buffer()
                end,
                -- Performance settings to make completion feel instant
                performance = {
                    debounce = 0,
                    throttle = 0,
                },

                -- UI Formatting for the completion menu
                formatting = {
                    format = function(entry, vim_item)
                        -- Concatenate the icon with the kind name (e.g., "󰊕 Function")
                        vim_item.kind = string.format(
                            "%s %s",
                            kind_icons[vim_item.kind],
                            vim_item.kind
                        )
                        -- Hide the source text (like "nvim_lsp") in the menu to keep it clean
                        vim_item.menu = ({
                            nvim_lsp = "",
                            luasnip = "",
                            nvim_lua = "",
                            latex_symbolc = "",
                        })[entry.source.name]
                        return vim_item
                    end,
                    expandable_indicator = false,
                    fields = { "abbr", "kind", "menu" }, -- Order of fields in the menu
                },

                -- How to handle snippet expansion
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- Use LuaSnip to expand snippets
                    end,
                },

                -- Completion behavior options
                completion = {
                    completeopt = "menu,menuone,noinsert", -- Show menu even for one item, don't insert text automatically
                },

                -- Keymappings for the completion menu
                mapping = {
                    -- Navigate down the list (behavior = insert text into buffer)
                    ["<C-n>"] = cmp.mapping.select_next_item({
                        behavior = cmp.SelectBehavior.Insert,
                    }),
                    -- Navigate up the list
                    ["<C-p>"] = cmp.mapping.select_prev_item({
                        behavior = cmp.SelectBehavior.Insert,
                    }),
                    -- Scroll documentation window
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    -- Confirm selection with Enter
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),

                    -- Arrow keys to navigate menu without inserting text immediately
                    ["<Down>"] = {
                        i = cmp.mapping.select_next_item({
                            behavior = types.cmp.SelectBehavior.Select,
                        }),
                    },
                    ["<Up>"] = {
                        i = cmp.mapping.select_prev_item({
                            behavior = types.cmp.SelectBehavior.Select,
                        }),
                    },
                    -- Toggle completion menu with Ctrl+Space
                    ["<C-space>"] = function()
                        if cmp.visible() then
                            cmp.abort()
                        else
                            cmp.complete()
                        end
                    end,
                },

                -- Define where completion items come from and their priority
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },  -- LSP suggestions
                    { name = "luasnip" },   -- Snippets
                    { name = "path" },      -- Filesystem paths (type ./ to activate)
                    { name = "dap",     max_item_count = 10 } -- Debugger variables
                }),

                -- Visual style for the completion and docs windows (add borders)
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },

                -- Matching algorithm settings
                matching = {
                    disallow_partial_fuzzy_matching = false,
                },

                -- Sorting logic for completion items
                sorting = {
                    comparators = {
                        compare.offset,
                        compare.exact,
                        compare.kind,
                        compare.score,
                        compare.recently_used,
                        compare.locality,
                        compare.sort_text,
                        compare.length,
                        compare.order,
                    },
                },
            }

            -- Set scroll offset (keep 5 items visible above/below cursor in menu)
            opts.window.completion.scrolloff = 5
            -- Apply the configuration
            cmp.setup(opts)
        end,
    },

    -- 2. Configuration for nvim-autopairs
    -- Automatically adds closing brackets, quotes, etc.
    {
        'windwp/nvim-autopairs',
        dependency = {
            "hrsh7th/nvim-cmp",
        },
        event = 'InsertEnter',
        config = function()
            require("nvim-autopairs").setup({})

            -- Integration with nvim-cmp:
            -- If you accept a function completion (e.g., "fmt.Println"),
            -- this automatically adds the opening parenthesis "(".
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
        end,
    },

    -- 3. Configuration for nvim-surround
    -- Quickly add, change, or delete surrounding characters (quotes, brackets, tags)
    {
        "kylechui/nvim-surround",
        version = "^3.0.0", -- Pin version for stability
        event = "VeryLazy", -- Load later to not block startup
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },

    -- 4. Configuration for LuaSnip specifically
    -- Handles snippet expansion and jumping between snippet placeholders
    {
        "L3MON4D3/LuaSnip",
        config = function()
            require("luasnip").config.setup({ history = true })
        end,
        -- Keymaps to jump forward/backward inside a snippet
        keys = {
            { "<c-n>", function() require("luasnip").jump(1) end,  mode = { "i", "s" } }, -- Jump forward
            { "<c-p>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } }  -- Jump backward
        },
    }
}
