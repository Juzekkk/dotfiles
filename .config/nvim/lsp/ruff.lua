--------------------------------------------------------------------------------
-- ruff — Python linter and formatter
--------------------------------------------------------------------------------
-- Replaces flake8 + isort + black in one binary. Its hover is disabled in
-- lua/lsp.lua (basedpyright provides that) and formatting goes through conform
-- rather than the LSP.
--
-- Install:
--   pipx install ruff
--   uv tool install ruff
--   cargo install ruff
--
-- Configure rules per project in pyproject.toml ([tool.ruff]) or ruff.toml.
--------------------------------------------------------------------------------
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  settings = {
    -- Global defaults; a config file in the project takes precedence
    lint = { enable = true },
    organizeImports = true,
  },
}
