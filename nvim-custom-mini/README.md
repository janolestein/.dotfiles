# Minimal Neovim Config (0.12+)

A LazyVim-flavored config with the smallest dependency footprint that still
keeps the LazyVim experience: fuzzy picker, file explorer, git signs,
which-key hints, statusline, bufferline, dashboard, LSP, completion, and the
editing niceties (surround, pairs, text objects, bracket motions).

**Two plugins at the core** — `mini.nvim` + `nvim-treesitter` — plus two optional
add-ons: [`tokyonight.nvim`](https://github.com/folke/tokyonight.nvim) (the
authentic LazyVim theme) and [`mason.nvim`](https://github.com/mason-org/mason.nvim)
(one-command LSP server installs). Everything else is built-in Neovim.

## The two core plugins

| Plugin            | What it provides                                                  |
| ----------------- | ----------------------------------------------------------------- |
| `mini.nvim`       | picker, explorer, statusline, bufferline, git signs, which-key, dashboard, notifications, pairs, surround, text objects, bracket motions, indent guides — **and the colorscheme** |
| `nvim-treesitter` | treesitter parser installer for languages Neovim doesn't bundle   |

`mini.nvim` is a library of ~40 small modules from one repo. We enable a
generous subset of them, but it's still **one git repository, one update
stream, one thing to trust**.

> `nvim-treesitter` was archived in April 2026, but its `main` branch is the
> 0.12-compatible rewrite and keeps working — it's just in maintenance mode.
> See "Going to one plugin" below if you want to drop it.

## Everything else is built into Neovim 0.12

| Feature                | Built-in used                       | Plugin it replaces            |
| ---------------------- | ----------------------------------- | ----------------------------- |
| Plugin manager         | `vim.pack`                          | lazy.nvim (no bootstrap)      |
| LSP setup              | `vim.lsp.config` / `vim.lsp.enable` | nvim-lspconfig                |
| Autocompletion         | `vim.lsp.completion` (autotrigger)  | nvim-cmp / blink              |
| Snippet expansion/jump | `vim.snippet`                       | LuaSnip                       |
| Commenting (`gc`)      | built-in commentstring commenting   | Comment.nvim                  |
| Inlay hints            | `vim.lsp.inlay_hint`                | lsp-inlayhints.nvim           |
| Diagnostic signs       | `vim.diagnostic.config`             | manual sign defines           |
| Highlight on yank      | `vim.hl.on_yank`                    | vim-highlightedyank           |
| Treesitter folds       | `vim.treesitter.foldexpr()`         | nvim-ufo                      |
| Float borders          | `'winborder'`                       | per-window border hacks       |
| Faster startup         | `vim.loader.enable()`               | impatient.nvim                |
| Lazygit / terminal     | `nvim_open_win` + `jobstart`        | toggleterm / snacks.terminal  |

## Install

```bash
nvim --version | head -1          # must be 0.12.0 or newer
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
cp -r nvim ~/.config/nvim
nvim                              # vim.pack prompts to install — press 'a'
```

Treesitter parsers install automatically (a `PackChanged` hook runs `TSUpdate`).
That needs `tree-sitter-cli` and a C compiler on your `$PATH`.

## Language servers (installed by Mason)

Server binaries are installed by [Mason](https://github.com/mason-org/mason.nvim),
set up at the top of `lua/config/lsp.lua`. Mason prepends its `bin/` to `$PATH`, so
the natively-configured servers are found automatically — no `mason-lspconfig`. The
`ensure` list in `lsp.lua` auto-installs the servers on the next launch; trim it to
the languages you use, or set it to `{}` and run `:Mason` / `:MasonInstall <name>`
by hand. Prefer your system package manager? Mason is optional — installing the
binaries yourself still works exactly as before:

```bash
brew install lua-language-server                       # Lua
npm  install -g typescript typescript-language-server  # TS/JS
npm  install -g pyright                                # Python
rustup component add rust-analyzer                     # Rust
go   install golang.org/x/tools/gopls@latest           # Go
brew install llvm                                      # clangd (C/C++)
npm  install -g bash-language-server                   # Bash
npm  install -g vscode-langservers-extracted           # JSON/HTML/CSS
npm  install -g yaml-language-server                   # YAML
npm  install -g @tailwindcss/language-server           # Tailwind
brew install marksman                                  # Markdown
brew install jdtls                                     # Java (needs a JDK 21+)
npm  install -g @angular/language-server typescript    # Angular (ngserver)
```

### Java + Spring notes

`jdtls` is the Eclipse Java language server; install the `jdtls` wrapper
(`brew install jdtls` or `yay -S jdtls`) and make sure a **JDK 21 or newer** is
on your `$PATH` to run it (it can still build projects targeting older Java).
Each project gets its own workspace under `~/.cache/nvim/jdtls/<project>`
automatically.

**Lombok** (used by almost every Spring project): download `lombok.jar` and put
it at `~/.local/share/nvim/lombok.jar`. The config auto-detects it and loads the
javaagent, so Lombok-generated getters/setters/builders stop showing as errors.

```bash
curl -L https://projectlombok.org/downloads/lombok.jar \
  -o ~/.local/share/nvim/lombok.jar
```

jdtls handles all Java/Spring code intelligence (beans, annotations, etc. are
just Java). If you also want `application.properties`/`.yaml` completion and
Spring endpoint navigation, that comes from the separate **Spring Boot Language
Server**, which is more involved to wire up natively — skipped here to stay
minimal.

### Angular notes

Install gives you the `ngserver` binary; it reads the Angular and TypeScript
versions from each project's own `node_modules`, so run `npm install` in the
project first. Component templates (`*.component.html`) are treated as the
`htmlangular` filetype and handled by `angularls` (the generic HTML server would
choke on `*ngIf`, `[bindings]`, and `{{ }}`). `ts_ls` and `angularls` both
attach to `.ts` files on purpose — general TypeScript from one, Angular template
type-checking and component↔template jumps from the other.

A server only starts when its command is found on `$PATH`, so unused ones cost
nothing. Add a server by adding a `vim.lsp.config("name", {...})` block in
`lua/config/lsp.lua` and listing it in the `vim.lsp.enable({...})` call.
Use `:checkhealth vim.lsp` or the new `:lsp` command to inspect clients.

## Key bindings

Leader is `<space>`. Press it and wait — `mini.clue` shows the available keys.

| Key             | Action                          |
| --------------- | ------------------------------- |
| `<leader><spc>` | find files                      |
| `<leader>ff`    | find files                      |
| `<leader>fg`    | git files                       |
| `<leader>fr`    | recent files                    |
| `<leader>fb`    | buffers                         |
| `<leader>/`     | live grep                       |
| `<leader>sw`    | grep word under cursor          |
| `<leader>sd`    | diagnostics picker              |
| `<leader>sk`    | keymaps picker                  |
| `<leader>ss`    | document symbols                |
| `<leader>e`     | file explorer (mini.files)      |
| `<leader>gg`    | lazygit (floating terminal)     |
| `<leader>gd`    | git diff overlay                |
| `<leader>gb`    | git blame                       |
| `<C-/>`         | floating terminal               |
| `gd gr gI gy`   | LSP definition/refs/impl/type   |
| `K`             | hover                           |
| `<leader>ca`    | code action                     |
| `<leader>cr`    | rename                          |
| `<leader>cf`    | format                          |
| `]h [h`         | next/prev git hunk              |
| `]d [d`         | next/prev diagnostic (mini.bracketed) |
| `]b [b`         | next/prev buffer (mini.bracketed)     |
| `]q [q`         | next/prev quickfix (mini.bracketed)   |
| `<leader>pu`    | update plugins (vim.pack)       |

`mini.bracketed` provides many more `]x`/`[x` pairs (indent, treesitter node,
comment, file, jump, undo, window, yank).

## Layout

```
~/.config/nvim/
├── init.lua                 entry: vim.loader, leader, requires
├── nvim-pack-lock.json      generated by vim.pack — commit it
└── lua/config/
    ├── options.lua          vim.opt settings + diagnostics config
    ├── keymaps.lua          global keymaps + floating terminal
    ├── autocmds.lua         autocommands
    ├── plugins.lua          vim.pack.add() + every mini module + treesitter
    └── lsp.lua              all LSP servers + completion + LspAttach
```

## Customizing

- **Authentic LazyVim look (tokyonight):** add
  `"https://github.com/folke/tokyonight.nvim"` to the `vim.pack.add({...})`
  list in `plugins.lua`, then replace `vim.cmd.colorscheme("miniwinter")` with
  `vim.cmd.colorscheme("tokyonight")`. (Now 3 plugins.)
- **Richer completion:** if native completion feels too plain, swap in
  `mini.completion` (free — already part of mini.nvim). In `plugins.lua` add
  `require("mini.completion").setup()`, and in `lsp.lua` remove the
  `vim.lsp.completion.enable(...)` line.
- **A different language:** add a `vim.lsp.config(...)` block + the parser name
  to the treesitter `want` list.

## Going to one plugin (drop nvim-treesitter)

Neovim 0.12 ships treesitter parsers for c, lua, markdown, query, vim, and
vimdoc, and highlights them automatically. For everything else, Neovim falls
back to its built-in regex syntax highlighting (which exists for python, rust,
go, js, and most languages), and LSP **semantic tokens** add another accurate
layer on top for any language with a running server.

If that's good enough for you, delete the `nvim-treesitter` line from
`vim.pack.add`, delete the `require("nvim-treesitter")...` block and the
`PackChanged` hook in `plugins.lua`, remove the `indentexpr` autocmd in
`autocmds.lua`, and run `:lua vim.pack.del({ "nvim-treesitter" })`. You're left
with **one plugin: mini.nvim**. The tradeoff is regex-grade (not
treesitter-grade) highlighting for non-bundled languages and no treesitter
folds/text-objects there.

## Requirements

- **Neovim 0.12.0+**
- A **Nerd Font** in your terminal (icons)
- `git`, `ripgrep`, `fd` (picker grep + file finding)
- `tree-sitter-cli` + a C compiler (parser compilation)
- `lazygit` (for `<leader>gg`)
