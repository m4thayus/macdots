# Diagnostics Styling

This config keeps Neovim's diagnostic behavior mostly default, with a few targeted
visual tweaks to make inline messages readable without overwhelming the buffer.

## Defaults (from core + theme)

- Signs in the gutter use severity icons when `vim.g.have_nerd_font` is true.
- Underline is enabled for errors only.
- Virtual text is enabled with `source = "if_many"` and `spacing = 2`.
- Diagnostic floats use the theme defaults and are opened on demand.

## Current Overrides (local config)

- Virtual text is italicized and dimmed by severity so errors are most prominent
  and hints are least distracting.
- Virtual text prefix is a simple ASCII `>` plus a trailing space to avoid
  duplicate severity symbols (the gutter already shows them).
- Base diagnostic groups and floating diagnostics keep the theme defaults.

## Severity Dimming Ramp

The dimming is applied in the colorscheme overrides by blending each diagnostic
color toward the background.

- Error: 0.0 (full intensity)
- Warn: 0.1 dim
- Info: 0.2 dim
- Hint: 0.3 dim

You can change the dim amounts in `lua/plugins/colorscheme.lua`:

```lua
local dim = function(hex, amount)
  return Color(hex):brighten(-amount, theme.ui.bg):to_hex()
end
```

## Where To Change Things

- Diagnostic behavior (signs, underline, virtual text):
  `lua/plugins/lspconfig.lua` (`vim.diagnostic.config { ... }`)
- Theme-specific highlight overrides:
  `lua/plugins/colorscheme.lua` (`require("kanagawa").setup { overrides = ... }`)

## Useful Commands

- Open a diagnostic float at the cursor:
  `:lua vim.diagnostic.open_float(0, { scope = "cursor" })`
