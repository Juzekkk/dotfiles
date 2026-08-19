# Neovim configuration

No plugin manager beyond the built-in `vim.pack`, no Node.js, no Mason.
15 plugins, native LSP, servers configured in `lsp/*.lua`.

## 📦 Requirements

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

## 🚀 Install

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

## 🗂️ Layout

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

The order in `init.lua` is not arbitrary:

```mermaid
flowchart LR
    accTitle: Configuration load order
    accDescr: Leader must be set before keymaps, options before plugins, and packages before any module that requires a plugin.

    leader["1 leader<br/>mapleader"]
    opts["2 options.lua"]
    pack["3 packages.lua<br/>vim.pack.add"]
    keys["4 keymaps.lua"]
    mods["5 ui / editor / lsp / debugging"]
    auto["6 autocmds.lua"]

    leader --> opts --> pack --> keys --> mods --> auto

    classDef critical fill:#fee2e2,stroke:#dc2626,stroke-width:2px,color:#7f1d1d
    classDef normal fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e3a5f

    class leader,pack,keys critical
    class opts,mods,auto normal
```

The three red steps fail quietly if you reorder them. A leader set after the
keymaps records `<leader>` as `\`. A module that requires `fzf-lua` before
`packages.lua` dies with "module not found". And keymaps registered after
`ui.lua` can be missing from the which-key popup, because which-key builds its
prefix tree from the keymaps that exist when it initialises.

## 📁 Working directory

`nvim some/folder` changes into that folder and opens the tree rooted there.
Neovim on its own would leave the working directory wherever you launched from,
which quietly breaks grep, the picker and LSP root detection. The `VimEnter`
handler in `lua/autocmds.lua` does the `:cd`, and nvim-tree follows through
`sync_root_with_cwd`.

If you opened a file by path and ended up in the wrong project, `<leader>cd`
moves the working directory to the nearest ancestor holding `.git`,
`Cargo.toml` or `pyproject.toml`.

## ⌨️ Keymaps

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
| `<leader>ro` | open docs.rs for the symbol |
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
| `<leader>td` | cycle diagnostic display: float → inline → cursor line → off |
| `<leader>tD` | diagnostics on/off, gutter signs included |
| `<leader>ts` | completion popup, ghost text and signature help on/off |
| `<leader>tf` | format on save |
| `<leader>th` | inlay hints |
| `<leader>tb` | inline git blame |
| `<leader>tc` | column guide (`colorcolumn`) |

`<leader>td` exists for the half-written-code case: save mid-thought and clippy
flags nearly every line, so the end-of-line messages bury the code. Gutter
signs stay on at every level, so you still know which lines have problems.

The default level, `float`, puts nothing inline at all. Rest the cursor on a
problem and a window opens with the explanation; move off it and the window
goes. For Rust that window shows the full cargo rendering — code frame, carets,
notes — the same text `<leader>rD` gives you, because rust-analyzer ships it in
the diagnostic's `data.rendered` field and the formatter in `lua/keymaps.lua`
prefers it over the one-line message. Other languages fall back to the plain
message.

Two things have to be cleaned off that text before it is readable. rustaceanvim
asks cargo for ANSI-coloured output so its own renderer can turn the escape
codes into highlights; `open_float` cannot, so the codes are stripped first.
And rust-analyzer emits its suggested fix as a second diagnostic that the cargo
frame already spells out, so the formatter returns `nil` for it and the
numbering prefix is dropped, which keeps the carets lined up with the code.

`<leader>rD` still has its own job: it cycles to the next diagnostic anywhere
in the file, whereas the float only reacts to what is under the cursor. The
float triggers on `CursorHold`, so `updatetime` in `lua/options.lua` (250 ms)
is the delay before it appears, and it uses `scope = "cursor"` — the cursor has
to sit inside the diagnostic's range, not merely somewhere on the line. Change
that to `"line"` for the looser behaviour.

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

## ⚠️ Known traps

| Symptom | Cause |
| --- | --- |
| No LSP completions | server not on PATH; check `:lsp` and `:checkhealth vim.lsp` |
| No syntax colours | `tree-sitter-cli` missing; run `:TSUpdate` |
| Breakpoint sign invisible | run `:lua =vim.fn.sign_getdefined("DapBreakpoint")` — an empty `text` field means the glyph got stripped when the file was copied |
| Two hovers in Python | ruff's hover should be off; see the end of `lua/lsp.lua` |
| Two clients on a `.rs` file | never enable `rust_analyzer` through `vim.lsp.enable` — rustaceanvim owns it |
| `<A-j>` does nothing | the terminal is eating Alt; in Kitty set `macos_option_as_alt yes` |
| A keymap is missing from which-key | `:verbose map <leader>td` tells you whether the mapping exists at all; if it does, it is a which-key discovery problem, so check `:checkhealth which-key` and the load order in `init.lua` |
| Colours look inconsistent | LSP semantic tokens are off by default; see the colours section |

## 🎨 Colours and borders

The theme is everforest (`hard` background). Switching is two lines: the entry
in `lua/packages.lua` and the `setup()` block at the top of `lua/ui.lua`.

Floating windows have no visible frame. Two settings produce that:

1. `vim.g.ui_border = "solid"` in `lua/options.lua` makes Neovim draw each
   border cell as a space instead of a box-drawing character. Every float in
   the config reads this one variable, so changing it to `"rounded"`,
   `"single"` or `"none"` moves everything at once.
2. `flatten_borders()` in `lua/ui.lua` links each border highlight group to
   its window group, so the ring of spaces takes the float's own background
   and reads as padding rather than a frame.

Step 2 is the part that matters. A `rounded` border draws an arc glyph on a
rectangular background cell, so the corner still looks square no matter what
font you use. NvChad sidesteps this the same way, which is what its
`telescope = { style = "borderless" }` default does under the hood.

LSP semantic tokens are switched off at the end of the `LspAttach` callback in
`lua/lsp.lua`. coc.nvim never sent them, so under the old setup treesitter did
all the colouring on its own. The native client does send them and they paint
over treesitter at a higher priority, which is what made everforest look like
it was drifting. Delete the `semanticTokensProvider` line to get them back.
`:Inspect` on any word shows which layer is painting it.

`vim.pack` has no lazy loading. With these 15 plugins startup is 40–60 ms.
If you grow to several dozen, measure with `nvim --startuptime /tmp/st.log`
before treating it as a problem.
