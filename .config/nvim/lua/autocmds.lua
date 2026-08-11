--------------------------------------------------------------------------------
-- AUTOCOMMANDS
--------------------------------------------------------------------------------
local function augroup(name)
  return vim.api.nvim_create_augroup("cfg-" .. name, { clear = true })
end

--------------------------------------------------------------------------------
-- `nvim some/folder` should actually work in that folder
--------------------------------------------------------------------------------
-- Neovim opens a buffer for the directory but leaves the working directory
-- wherever you launched from, so pickers, grep and the LSP root all end up
-- pointing at the wrong place. Change into it and let nvim-tree follow.
--
-- nvim-tree has sync_root_with_cwd = true, so the :cd fires DirChanged and
-- the tree re-roots itself even if it opened at the old path first.
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("dir-arg"),
  callback = function()
    if vim.fn.argc() ~= 1 then
      return
    end
    local arg = vim.fn.argv(0)
    if type(arg) ~= "string" or vim.fn.isdirectory(arg) == 0 then
      return
    end

    local dir = vim.fn.fnamemodify(arg, ":p")
    vim.cmd.cd(dir)

    -- Drop the placeholder directory buffer Neovim created for the argument
    local buf = vim.api.nvim_get_current_buf()
    if vim.fn.isdirectory(vim.api.nvim_buf_get_name(buf)) == 1 then
      vim.api.nvim_buf_delete(buf, { force = true })
    end

    require("nvim-tree.api").tree.open({ path = dir })
  end,
})

--------------------------------------------------------------------------------
-- Editing niceties
--------------------------------------------------------------------------------
-- Flash the region you just yanked.
-- WAS: vim.highlight.on_yank — that name is deprecated since 0.11.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("yank"),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Equalise splits after the terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize"),
  callback = function()
    local tab = vim.api.nvim_get_current_tabpage()
    vim.cmd("tabdo wincmd =")
    vim.api.nvim_set_current_tabpage(tab)
  end,
})

-- Reopen a file where you left it
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last-position"),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Do not continue comments on Enter or with `o`.
-- Has to be a FileType autocmd because every ftplugin resets formatoptions.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("formatoptions"),
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- Create missing parent directories when writing a new file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then
      return
    end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
  end,
})
