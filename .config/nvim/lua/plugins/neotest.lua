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
      "<leader>tn",
      function()
        require("neotest").run.run()
      end,
      desc = "[T]est [N]earest",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      desc = "[T]est current [F]ile",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle [T]est [S]ummary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open { enter = true, auto_close = true }
      end,
      desc = "Show [T]est [O]utput",
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
