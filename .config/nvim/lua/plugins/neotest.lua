return {
  "nvim-neotest/neotest",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    "olimorris/neotest-rspec",
    "marilari88/neotest-vitest",
  },
  keys = {
    {
      "<leader>tt",
      function()
        require("neotest").run.run()
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>tT",
      function()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      desc = "Run tests in file",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle test summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open { enter = true, auto_close = true }
      end,
      desc = "Show test output",
    },
  },
  config = function()
    local neotest = require "neotest"

    ---@diagnostic disable-next-line: missing-fields
    neotest.setup {
      adapters = {
        require "neotest-rspec" {},
        require "neotest-vitest" {},
      },
    }
  end,
}
