# Neovim Configuration

Opinionated Neovim setup built on Kickstart-style modules and managed
by `lazy.nvim`. It ships with sensible defaults, LSP/completion,
formatting, Telescope search, tree navigation, and test runners.

## Requirements

- Neovim >= 0.11
- Tooling: `git`, `make`, `unzip`, `rg`
- Optional: Nerd Font for icons
- Optional: Node toolchain for JS/TS tooling
- Optional: `~/.rbenv/shims/ruby-lsp` for Ruby LSP code lenses
- Optional: `stylua`, `prettier` or `prettierd`, `coffeelint`

## Getting Started

1. Install (or clone) into `~/.config/nvim`.
2. Sync plugins:

   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```

3. Launch `nvim` and run `:checkhealth` for environment validation.

> [!TIP]
> `init.lua` has the leader key commented out. Uncomment
> `vim.g.mapleader = " "` if you want Space as leader (default is `\`).

## Layout

- Entry point: `init.lua` wires `lua/options.lua`, `lua/filetypes.lua`,
  `lua/keymaps.lua`, `lua/lazy-bootstrap.lua`, and `lua/lazy-plugins.lua`.
- Plugin specs: `lua/plugins/*.lua`; add overrides in
  `lua/plugins/custom/`.
- Lockfile: `lazy-lock.json` (keep in sync when updating plugins).

## Core Features & Keymaps

- **Search (Telescope)**: `<leader>sf` files, `<leader>sg` live grep,
  `<leader>sw` word under cursor, `<leader>sd` diagnostics,
  `<leader>sh` help tags, `<leader>sr` resume, `<leader>s/` open-file
  grep, `<leader>b` buffers, `<leader>/` current-buffer fuzzy find.
- **File tree (neo-tree)**: `<leader>\` toggles reveal/close.
- **Diagnostics & LSP**: `<leader>q` opens loclist; `grd/grr/gri/grt`
  jump; `grn` rename; `gra` code action; `gO/gW` symbols; `<leader>th`
  toggle inlay hints; `<leader>cl` run code lens; `gl` opens diagnostic
  float. See `docs/DIAGNOSTICS-STYLING.md` for styling tweaks.
- **Completion (blink.cmp)**: super-tab preset; `<Tab>/<S-Tab>` to
  navigate snippets, `<C-Space>` docs, `<C-k>` signature help.
- **Formatting (conform.nvim)**: `<leader>f` formats buffer; format on
  save (except C/C++) using `stylua` and `prettier/prettierd`.
- **Linting (nvim-lint)**: `markdownlint-cli2` for Markdown,
  `coffeelint` for CoffeeScript. Trigger with
  `:lua require("lint").try_lint()`.
- **Testing (neotest)**: `<leader>tn` nearest, `<leader>tf` file,
  `<leader>ts` summary, `<leader>to` output. Adapters for RSpec and
  Vitest are prewired.
- **Git (gitsigns)**: `]c/[c` next/prev hunk; `<leader>hs` stage,
  `<leader>hr` reset, `<leader>hp` preview, `<leader>hb` blame.
- **Text objects & surrounds (mini.nvim)**: `mini.ai` extends
  textobjects; `mini.surround` uses `sa/sd/sr` for add/delete/replace.

## Language Support

- **LSP**: Managed by Mason (`:Mason`). Defaults include `lua_ls`,
  `codebook`, `eslint`, `stylelint_lsp`, `ruby_lsp`, and `coffeesense`.
  TypeScript/JS use `typescript-tools.nvim` with blink.cmp capabilities.
  `lazydev.nvim` enhances Lua completion for Neovim APIs.
- **Treesitter**: Parsers installed for common languages (Lua, Ruby,
  JS/TS, HTML/CSS/SCSS, Terraform, SQL, YAML, and more) with
  per-filetype autostart; indentation stays regex-based for Ruby.
- **CoffeeScript**: Filetypes from `vim-coffee-script`, LSP via
  `coffeesense-language-server`, lint via `coffeelint`.

## Appearance & UI

- Colorscheme: Kanagawa (dragon variant).
- Statusline: `mini.statusline` with Nerd Font support.
- UI helpers: which-key, indent guides, guess-indent, todo-comments,
  autopairs.

## Maintenance

- Update plugins: `:Lazy update` (review `lazy-lock.json` afterward).
- Reinstall/ensure tools: `:Mason` or rerun headless `Lazy! sync`.
- Health check: `nvim --headless "+checkhealth" +qa`.

## Customization Pointers

- Set `vim.g.have_nerd_font = true` in `init.lua` for icon support
  (default on).
- Add new plugins under `lua/plugins/custom/` to keep local changes
  isolated.
- Adjust formatters and linters in `lua/plugins/conform.lua` and
  `lua/plugins/lint.lua`; add LSP servers in `lua/plugins/lspconfig.lua`.

Happy editing! If anything feels off, open `:help` or use `<leader>sh`
to fuzzy-search Neovim docs.
