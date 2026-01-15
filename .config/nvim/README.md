# Neovim Configuration

Opinionated Neovim setup built on Kickstart-style modules and managed
by `lazy.nvim`. It ships with sensible defaults, LSP/completion/formatting,
tree navigation, Telescope search, and test runners for common
stacks.

## Requirements

- Neovim >= 0.10
- Tooling: `git`, `make`, `unzip`, `rg`
- Optional: Nerd Font for icons, `rbenv`-installed `ruby-lsp` shim
(`~/.rbenv/shims/ruby-lsp`), Node toolchain for TypeScript/JS
language tools

## Getting Started

1) Install (or clone) into `~/.config/nvim`.
2) Sync plugins:

   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```

3) Launch `nvim` and run `:checkhealth` for environment validation.

> Tip: `init.lua` has the leader key commented out. Uncomment
`vim.g.mapleader = " "` if you want Space as leader (default is
`\`).

## Layout

- Entry point: `init.lua` wires `lua/options.lua`, `lua/filetypes.lua`,
`lua/keymaps.lua`, `lua/lazy-bootstrap.lua`, and `lua/lazy-plugins.lua`.
- Plugin specs: `lua/plugins/*.lua`; add local overrides in `lua/plugins/custom/`.
- Lockfile: `lazy-lock.json` (keep in sync when updating plugins).

## Core Features & Keymaps

- **Search (Telescope)**: `<leader>sf` files, `<leader>sg` live
grep, `<leader>sh` help tags, `<leader>sr` resume, `<leader>b`
buffers. `</>` maps to current-buffer fuzzy find.
- **File tree (neo-tree)**: `<leader>\` toggles reveal/close in the sidebar.
- **Diagnostics**: `<leader>q` opens diagnostic quickfix; LSP symbols/defs via `grd/gri/grr/gW/gO/grt`.
- **Completion (blink.cmp)**: super-tab preset; `<Tab>/<S-Tab>`
navigate snippets, `<C-Space>` toggle docs, `<C-k>` signature help.
- **Formatting (conform.nvim)**: `<leader>f` formats buffer; saves
format automatically (except C/C++) using `stylua` or `prettier/prettierd`
where available.
- **Linting (nvim-lint)**: markdownlint on Markdown; extend via
`lint.linters_by_ft`. Trigger manually with `:lua
require("lint").try_lint()`.
- **Testing (neotest)**: `<leader>tn` nearest, `<leader>tf` file,
`<leader>ts` summary, `<leader>to` output. Adapters for RSpec and
Vitest prewired.

## Language Support

- **LSP**: Managed by Mason (`:Mason`). Defaults include `lua_ls`,
`codebook`, `eslint`, `stylelint_lsp`, and `ruby_lsp` (with code
lens + Rails/RSpec commands). TypeScript/JS use `typescript-tools.nvim`
with blink.cmp capabilities.
- **Treesitter**: Parsers installed for common languages (Lua, Ruby,
JS/TS, HTML/CSS/SCSS, Terraform, SQL, YAML, etc.) with per-filetype
autostart; indentation disabled for Ruby to keep regex-based
indenting.

## Appearance & UI

- Colorscheme: Kanagawa (dragon variant) set in `lua/plugins/colorscheme.lua`.
- Status/UX helpers: which-key, indent guides, gitsigns, todo-comments,
autopairs, mini.nvim basics.

## Maintenance

- Update plugins: `:Lazy update` (review `lazy-lock.json` afterward).
- Reinstall/ensure tools: `:Mason` or rerun headless `Lazy! sync`.
- Health check: `nvim --headless "+checkhealth" +qa`.

## Customization Pointers

- Set `vim.g.have_nerd_font = true` in `init.lua` for icon support (default on).
- Add new plugins under `lua/plugins/custom/` to keep local changes isolated.
- Adjust formatter/linters in `lua/plugins/conform.lua` and
`lua/plugins/lint.lua`; add LSP servers in `lua/plugins/lspconfig.lua`.

Happy editing! If anything feels off, open `:help` or use `<leader>sh`
to fuzzy-search Neovim docs.
