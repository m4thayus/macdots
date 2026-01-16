return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("kanagawa").setup {
        theme = "dragon",
        keywordStyle = { italic = false },
        overrides = function(colors)
          local theme = colors.theme
          local Color = require("kanagawa.lib.color")
          local dim = function(hex, amount)
            return Color(hex):brighten(-amount, theme.ui.bg):to_hex()
          end
          return {
            ["@variable.builtin"] = { italic = false },
            ["@constant.builtin"] = { italic = false },
            DiagnosticVirtualTextError = { fg = dim(theme.diag.error, 0), italic = true },
            DiagnosticVirtualTextWarn = { fg = dim(theme.diag.warning, 0.1), italic = true },
            DiagnosticVirtualTextInfo = { fg = dim(theme.diag.info, 0.2), italic = true },
            DiagnosticVirtualTextHint = { fg = dim(theme.diag.hint, 0.3), italic = true },
          }
        end,
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme "kanagawa-dragon"
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
