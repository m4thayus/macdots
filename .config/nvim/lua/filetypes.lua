-- Centralized custom filetype detection tweaks.
-- Slim templates often use `.html.slim`; Neovim doesn't detect that pattern by default,
-- so map those extensions to the `slim` filetype for proper treesitter highlighting.
vim.filetype.add({
  extension = { slim = "slim" },
  pattern = { [".*%.html%.slim"] = "slim" },
})

