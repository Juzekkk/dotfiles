# Neovim configuration

No plugin manager beyond the built-in `vim.pack`, no Node.js, no Mason.
15 plugins, native LSP, servers configured in `lsp/*.lua`.

## Requirements

Neovim **0.12+** (`nvim --version`). It refuses to load on 0.11 because
`vim.pack` does not exist there.

| Tool | Used for | Install |
| --- | --- | --- |
| `git` | vim.pack clones plugins | system package |
| `fzf` | picker | `brew install fzf` / `pacman -S fzf` |
| `ripgrep` | project grep | `brew install ripgrep` / `pacman -S ripgrep` |
| `tree-sitter-cli` | building parsers | `cargo install tree-sitter-cli` |
| `zoxide` | `<leader>z` | `brew install zoxide` / `pacman -S zoxide` |
| `lazygit` | `<leader>g` | `brew install lazygit` |
| Nerd Font | file icons | [nerdfonts.com](https://www.nerdfonts.com) |

Install `tree-sitter-cli` from cargo or your system package manager, not npm.
The npm build lacks what the nvim-treesitter `main` branch expects.

Gutter signs for diagnostics and breakpoints use plain geometric characters
(`● ◆ ▲ ✖`) rather than Nerd Font private-use glyphs, so they render even
without a patched font. Only file-type icons need one.

### Languages

| Language | Server | Debugger | Formatter |
| --- | --- | --- | --- |
| Rust | `rustup component add rust-analyzer` | `codelldb` on PATH | `rustfmt` (from rustup) |
| Python | `uv tool install basedpyright` + `uv tool install ruff` | `pip install debugpy` in the project venv | ruff |
| Lua | `lua-language-server` from your package manager | — | `cargo install stylua` |

Grab `codelldb` from the [vscode-lldb releases](https://github.com/vadimcn/codelldb/releases)
and put it on PATH. rustaceanvim finds it from there.

## Install

```bash
# 1. Keep what you have
mv ~/.config/nvim ~/.config/nvim.bak

# 2. Clear state left by lazy.nvim and coc.nvim
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim  ~/.local/state/nvim.bak
rm -rf ~/.config/coc          # coc extensions, hundreds of MB of node_modules

# 3. Drop in the new config
cp -r ./nvim ~/.config/nvim

# 4. Start it. vim.pack clones the plugins and shows you the list first.
nvim
```

Expect errors on the very first start until the treesitter parsers finish
building. Run `:restart`, then `:checkhealth`.

Roll back with `rm -rf ~/.config/nvim && mv ~/.config/nvim.bak ~/.config/nvim`.

## Layout

Neovim loads `lsp/` and `after/ftplugin/` by itself, off the runtimepath.
You never `require` anything from those two directories.

```
~/.config/nvim/
├── init.lua                 load order
├── nvim-pack-lock.json      generated; commit it
├── lua/
│   ├── options.lua          global options, netrw disabled
│   ├── packages.lua         vim.pack.add — the only plugin list
│   ├── ui.lua               colors, treesitter, statusline, which-key, gitsigns
│   ├── editor.lua           fzf-lua, nvim-tree, conform, blink.cmp
│   ├── lsp.lua              diagnostics, LspAttach, vim.lsp.enable
│   ├── debugging.lua        nvim-dap + dap-view
│   ├── keymaps.lua          global keymaps
│   └── autocmds.lua         autocommands, directory-argument handling
├── lsp/                     ← Neovim reads these itself
│   ├── lua_ls.lua
│   ├── basedpyright.lua
│   └── ruff.lua
└── after/ftplugin/          ← and these
    ├── rust.lua             rustaceanvim keymaps
    ├── python.lua           test-debugging keymaps
    ├── lua.lua
    ├── markdown.lua
    ├── help.lua / man.lua / qf.lua
```

## Working directory

`nvim some/folder` changes into that folder and opens the tree rooted there.
Neovim on its own would leave the working directory wherever you launched from,
which quietly breaks grep, the picker and LSP root detection. The `VimEnter`
handler in `lua/autocmds.lua` does the `:cd`, and nvim-tree follows through
`sync_root_with_cwd`.

If you opened a file by path and ended up in the wrong project, `<leader>cd`
moves the working directory to the nearest ancestor holding `.git`,
`Cargo.toml` or `pyproject.toml`.

## Keymaps

Leader is space. `<leader>sk` lists the live, complete set.

### Navigation

| Key | Action |
| --- | --- |
| `<leader>e` | toggle file tree |
| `<leader>E` | reveal current file in the tree |
| `<C-p>` / `<leader>f` | find file |
| `<leader>/` | grep project |
| `<leader><leader>` | files, buffers and symbols at once |
| `<leader>b` | buffers |
| `<leader>z` | zoxide |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `<C-hjkl>` | move between windows |

### Code

| Key | Action |
| --- | --- |
| `gd` / `gy` / `gi` / `gr` | definition / type / implementation / references |
| `K` | hover |
| `<F2>` / `<leader>cr` | rename |
| `<leader>ca` | code action |
| `<leader>cf` | format |
| `]d` / `[d` | next / previous diagnostic |
| `<leader>xx` | diagnostics list |
| `<Tab>` / `<CR>` | completion |

### Rust (only in `.rs` buffers)

| Key | Action |
| --- | --- |
| `<leader>rr` | runnables |
| `<leader>rd` | debuggables |
| `<leader>rt` | testables |
| `<leader>re` | explain error |
| `<leader>rm` | expand macro |
| `K` | hover with actions |

### Debug

| Key | Action |
| --- | --- |
| `<F5>` | start / continue |
| `<F9>` / `<leader>db` | toggle breakpoint |
| `<F10>` / `<F11>` / `<S-F11>` | over / into / out |
| `<leader>du` | toggle UI |
| `<leader>dl` | list breakpoints |
| `<leader>dn` | debug test under cursor (Python) |

### Toggles

| Key | Action |
| --- | --- |
| `<leader>tf` | format on save |
| `<leader>th` | inlay hints |
| `<leader>tv` | expanded diagnostics |
| `<leader>tb` | inline git blame |
| `<leader>tc` | column guide (`colorcolumn`) |

## 🔧 Maintenance

| Task | Command |
| --- | --- |
| Update plugins | `:lua vim.pack.update()` |
| Update one | `:lua vim.pack.update({ "fzf-lua" })` |
| List installed | `:lua =vim.pack.get()` |
| Undo an update | `git checkout HEAD -- nvim-pack-lock.json`, `:restart`, then `:lua vim.pack.update(nil, { offline = true, target = "lockfile" })` |
| Update parsers | `:TSUpdate` |
| LSP status | `:lsp` or `:checkhealth vim.lsp` |
| Restart a server | `:lsp restart` |

`vim.pack.update()` opens a buffer with the diff. Review it, `:w` to apply,
close without writing to discard.

### Adding a plugin

Add a line to `lua/packages.lua`, call its `setup()` in `ui.lua` or
`editor.lua`, then `:restart`.

### Removing a plugin

Delete it from `lua/packages.lua`, remove the `setup()` call, then
`:lua vim.pack.del({ "name" })`. Two separate steps: dropping it from the list
does not remove the files.

### Adding an LSP server

Create `lsp/<name>.lua` returning a table with `cmd`, `filetypes` and
`root_markers`, then add the name to `vim.lsp.enable({ ... })` in
`lua/lsp.lua`. The [lsp/ directory in nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/tree/master/lsp)
uses the identical format, so you can copy a file straight across.

## Known traps

| Symptom | Cause |
| --- | --- |
| No LSP completions | server not on PATH; check `:lsp` and `:checkhealth vim.lsp` |
| No syntax colours | `tree-sitter-cli` missing; run `:TSUpdate` |
| Breakpoint sign invisible | run `:lua =vim.fn.sign_getdefined("DapBreakpoint")` — an empty `text` field means the glyph got stripped when the file was copied |
| Two hovers in Python | ruff's hover should be off; see the end of `lua/lsp.lua` |
| Two clients on a `.rs` file | never enable `rust_analyzer` through `vim.lsp.enable` — rustaceanvim owns it |
| `<A-j>` does nothing | the terminal is eating Alt; in Kitty set `macos_option_as_alt yes` |

`vim.pack` has no lazy loading. With these 15 plugins startup is 40–60 ms.
If you grow to several dozen, measure with `nvim --startuptime /tmp/st.log`
before treating it as a problem.
