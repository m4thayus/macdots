return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local languages = {
        "bash",
        "c",
        "css",
        "diff",
        "dockerfile",
        "graphql",
        "html",
        "javascript",
        "json",
        "jsx",
        "latex",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "nginx",
        "query",
        "regex",
        "ruby",
        "scss",
        "slim",
        "sql",
        "ssh_config",
        "terraform",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      require("nvim-treesitter").setup()
      -- Install parsers asynchronously (no-op for already installed languages).
      require("nvim-treesitter").install(languages)

      local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "*",
        callback = function(event)
          -- Start treesitter highlighting when a parser is available.
          if pcall(vim.treesitter.start, event.buf) and vim.bo[event.buf].filetype ~= "ruby" then
            -- Enable treesitter indentation everywhere except Ruby (which relies on regex indent).
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
