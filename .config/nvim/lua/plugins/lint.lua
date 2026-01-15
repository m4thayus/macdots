return {

  { -- Linting
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require "lint"
      local normalize = (vim.fs and vim.fs.normalize) and vim.fs.normalize or function(path) return path end
      local function coffeelint_parser(output, bufnr, linter_cwd)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return {}
        end

        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or type(decoded) ~= "table" then
          return {}
        end

        local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
        local diagnostics = {}

        for file, entries in pairs(decoded) do
          local file_path
          if file:match("^%w:") or vim.startswith(file, "/") then
            file_path = file
          else
            file_path = vim.fn.simplify(linter_cwd .. "/" .. file)
          end

          if normalize(file_path) == normalize(buffer_path) then
            for _, entry in ipairs(entries or {}) do
              local rule = entry.rule or entry.name
              local message = entry.message or "Coffeelint issue"
              if rule and rule ~= "" then
                message = string.format("[%s] %s", rule, message)
              end

              local lnum = entry.lineNumber and math.max(entry.lineNumber - 1, 0) or 0
              local end_lnum = entry.lineNumberEnd and math.max(entry.lineNumberEnd - 1, lnum) or lnum
              local col = entry.columnNumber and math.max(entry.columnNumber - 1, 0) or 0
              local end_col = entry.columnNumberEnd and math.max(entry.columnNumberEnd - 1, col) or col
              local severity = entry.level == "warn" and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR

              diagnostics[#diagnostics + 1] = {
                lnum = lnum,
                end_lnum = end_lnum,
                col = col,
                end_col = end_col,
                severity = severity,
                message = message,
                source = "coffeelint",
              }
            end
          end
        end

        return diagnostics
      end

      lint.linters.coffeelint = {
        cmd = "coffeelint",
        stdin = false,
        args = { "--reporter=raw" },
        stream = "stdout",
        ignore_exitcode = true,
        parser = coffeelint_parser,
      }
      lint.linters_by_ft = {
        coffee = { "coffeelint" },
        litcoffee = { "coffeelint" },
        markdown = { "markdownlint-cli2" },

        -- stylelint-lsp handles linting support for relevant files
        -- css = { "stylelint" },
        -- scss = { "stylelint" },

        -- eslint LSP handles linting and code action support for relevant files
        -- javascript = { "eslint_d", "eslint" },
        -- javascriptreact = { "eslint_d", "eslint" },
        -- typescript = { "eslint_d", "eslint" },
        -- typescriptreact = { "eslint_d", "eslint" },

        -- Ruby LSP provides linting support for ruby via rubocop,
        -- ruby = { "rubocop" },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            -- try_lint without arguments runs the linters defined in `linters_by_ft`
            -- for the current filetype
            lint.try_lint()
            -- You can call `try_lint` with a linter name or a list of names to always
            -- run specific linters, independent of the `linters_by_ft` configuration
            -- require("lint").try_lint "cspell"
          end
        end,
      })
    end,
  },
}
