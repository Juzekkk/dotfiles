---------------------------------------------------------------------------------------
-- STATUS LINE PLUGIN
---------------------------------------------------------------------------------------

-- Helper function: Returns a string listing active LSP clients for the current buffer
local function lsp_status()
  -- Get clients attached to the current buffer (0)
  local attached_clients = vim.lsp.get_clients { bufnr = 0 }
  if #attached_clients == 0 then
    return ""
  end
  local names = {}
  for _, client in ipairs(attached_clients) do
    -- Shorten names to save space (e.g., "lua-language.server" -> "lua-ls")
    local name = client.name:gsub("language.server", "ls")
    table.insert(names, name)
  end
  return "LSP: " .. table.concat(names, ", ")
end

-- Helper function: Returns a string if a macro is currently being recorded
local function macro()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return "Recording macro in: " .. reg
end

return {
  -- status line plugin --
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy", -- Load after startup to prevent slowing down launch
  config = function()
    -- State variable to track if we are in debug mode
    local dmode_enabled = false

    -- Event Listener: Watch for the "DebugModeChanged" event
    -- (Likely triggered by the debugmaster plugin from your previous file)
    vim.api.nvim_create_autocmd("User", {
      pattern = "DebugModeChanged",
      callback = function(args)
        dmode_enabled = args.data.enabled
        require('lualine').refresh() -- Force status line to redraw with new state
      end
    })

    require("lualine").setup {
      options = {
        globalstatus = true, -- Use a single status line at the very bottom (not one per window)
        component_separators = { left = "", right = "" }, -- Clean look: no separators
        section_separators = { left = "", right = "" },
      },
      sections = {
        -- Leftmost section (Mode indicator)
        lualine_a = {
          {
            "mode",
            -- If debug mode is active, override text to "DEBUG", otherwise show "NORMAL/INSERT"
            fmt = function(str) return dmode_enabled and "DEBUG" or str end,
            -- If debug mode is active, change background color to "dCursor" highlight
            color = function(tb) return dmode_enabled and "dCursor" or tb end,
          },
        },
        lualine_b = {}, -- Empty section
        lualine_c = {
          { "filename", path = 1 }, -- 1 = Relative path
          { "branch" },             -- Git branch
          { "diff" },               -- Git added/modified/removed stats
          { "diagnostics" },        -- Errors and warnings
          { macro },                -- Custom macro recording indicator defined above
        },
        -- Right side sections
        lualine_x = {
          { lsp_status }, -- Custom active LSP list defined above
          { "filetype" }, -- e.g. "lua"
        },
        lualine_y = { { "progress" }, { "location" } }, -- % through file and Line:Column
        lualine_z = {}, -- Empty section
      },
      -- Configuration for inactive windows (less visible due to globalstatus=true)
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    }
  end,
}
