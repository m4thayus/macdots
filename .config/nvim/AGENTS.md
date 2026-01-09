# Repository Guidelines

## Project Structure & Module Organization
- Entry point is `init.lua`, which wires `lua/options.lua`, `lua/filetypes.lua`, `lua/keymaps.lua`, `lua/lazy-bootstrap.lua`, and `lua/lazy-plugins.lua`.
- Plugin specs live in `lua/plugins/*.lua`; add or override plugins in `lua/plugins/custom/` to keep local changes isolated.
- `lazy-lock.json` is managed by lazy.nvim; commit it alongside plugin updates so versions remain reproducible.

## Build, Test, and Development Commands
- Install/update plugins headlessly: `nvim --headless "+Lazy! sync" +qa` (or `:Lazy sync` interactively).
- Check environment and tool availability: `nvim --headless "+checkhealth" +qa`.
- Upgrade plugins: `:Lazy update` followed by reviewing changes in `lazy-lock.json`.
- Run formatter on the current buffer: `<leader>f` (conform.nvim) or CLI `stylua lua` after `mason-tool-installer` installs `stylua`.
- Trigger linters manually when needed: `:lua require("lint").try_lint()` (markdownlint is configured; stylelint/eslint/rubocop can be enabled once available).

## Coding Style & Naming Conventions
- Lua files use two-space indentation with `expandtab`; keep modelines (`ts=2 sts=2 sw=2 et`) intact.
- Prefer small, self-contained plugin specs; name plugin files with hyphenated names matching the plugin (e.g., `neo-tree.lua`).
- Use `vim.g.have_nerd_font = true` defaults; keep keymaps descriptive via `desc` for discoverability in which-key.

## Testing Guidelines
- Neotest adapters are enabled for RSpec and Vitest: `<leader>tn` runs the nearest test, `<leader>tf` runs the current file, `<leader>ts` toggles the summary, `<leader>to` opens output.
- For Ruby LSP code lenses, ensure `ruby-lsp` is available (shimmed via rbenv) so inline test/task commands work.
- When adding language support, verify LSP/formatter installs via `:Mason` and rerun `:checkhealth`.

## Commit & Pull Request Guidelines
- No existing history here; default to clear, imperative commit subjects (e.g., `feat: add neo-tree config`, `chore: update lazy lockfile`) and include `lazy-lock.json` changes with plugin updates.
- In pull requests, briefly describe scope, notable keymaps, and new dependencies; mention test signals (neotest runs, headless `Lazy! sync`, `checkhealth`) and include screenshots only when UI-affecting changes (statusline, tree, telescope) are made.

## Security & Configuration Tips
- Avoid committing machine-specific secrets or paths; use `lua/plugins/custom/` for local-only tweaks when possible.
- Mason installs formatters/linters/LSPs per user; document any required system tools (`git`, `make`, `unzip`, `rg`, Node/deno/ruby managers) if new dependencies are introduced.
