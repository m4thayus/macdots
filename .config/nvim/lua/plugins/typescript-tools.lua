return {
  "pmizio/typescript-tools.nvim",
  main = "typescript-tools",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  opts = function()
    return {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    }
  end,
}
