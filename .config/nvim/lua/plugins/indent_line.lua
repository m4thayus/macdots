return {
  { -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = "ibl",
    opts = {
      indent = {
        highlight = {
          "EndOfBuffer",
          "IblIndent",
          "IblIndent",
          "IblIndent",
          "IblIndent",
          "IblIndent",
          "IblIndent",
        },
        char = "▏",
        -- Default: `▎`
        --
        -- Alternatives:
        --   • left aligned solid
        --     • `▏`
        --     • `▎` (default)
        --     • `▍`
        --     • `▌`
        --     • `▋`
        --     • `▊`
        --     • `▉`
        --     • `█`
        --   • center aligned solid
        --     • `│`
        --     • `┃`
        --   • right aligned solid
        --     • `▕`
        --     • `▐`
        --   • center aligned dashed
        --     • `╎`
        --     • `╏`
        --     • `┆`
        --     • `┇`
        --     • `┊`
        --     • `┋`
        --   • right aligned dotted
        --     • `⋮`
        --     • `⁞`
        --   • center aligned double
        --     • `║`
      },
    },
  },
}
