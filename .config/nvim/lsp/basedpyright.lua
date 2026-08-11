--------------------------------------------------------------------------------
-- basedpyright — types, hover, go to definition
--------------------------------------------------------------------------------
-- A pyright fork with better defaults and inlay hints. Linting and formatting
-- belong to ruff (lsp/ruff.lua), hence the disabled rules that would otherwise
-- duplicate ruff's output.
--
-- Install:
--   pipx install basedpyright
--   uv tool install basedpyright
--
-- To use plain pyright instead: change cmd to { "pyright-langserver", "--stdio" },
-- rename the settings key from basedpyright to python, and swap the name in
-- vim.lsp.enable() in lua/lsp.lua.
--------------------------------------------------------------------------------
return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "pyrightconfig.json",
    ".git",
  },
  settings = {
    basedpyright = {
      disableOrganizeImports = true, -- ruff does this
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        -- "off" | "basic" | "standard" | "strict" | "all"
        typeCheckingMode = "standard",
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
        },
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none", -- ruff: F401
          reportUnusedVariable = "none", -- ruff: F841
          reportMissingImports = "warning",
        },
      },
    },
  },
}
