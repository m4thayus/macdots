-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      -- Handle ruby-lsp / ruby-lsp-rails custom commands that the client must implement.
      local ruby_lsp_codelens_setup_done = false
      local output_bufnr, output_winnr, append_position

      local function ensure_output_buf(command)
        if not (output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr)) then
          output_bufnr = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_name(output_bufnr, "Ruby LSP Command: " .. command)
          vim.bo[output_bufnr].bufhidden = "wipe"
          vim.bo[output_bufnr].buftype = "nofile"
          vim.bo[output_bufnr].swapfile = false
        end
        vim.bo[output_bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { "Running command: " .. command, "" })
      end

      local function ensure_output_win()
        local curwin = vim.api.nvim_get_current_win()
        if not (output_winnr and vim.api.nvim_win_is_valid(output_winnr)) then
          vim.cmd "botright split"
          output_winnr = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_height(output_winnr, 12)
        end
        vim.api.nvim_win_set_buf(output_winnr, output_bufnr)
        vim.api.nvim_win_set_option(output_winnr, "number", false)
        vim.api.nvim_win_set_option(output_winnr, "relativenumber", false)
        vim.api.nvim_set_current_win(curwin)
      end

      local function display_command_output(_, data)
        if not (data and output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr)) then
          return
        end
        append_position = append_position or 2
        vim.api.nvim_buf_set_lines(output_bufnr, append_position, append_position, false, data)
        append_position = append_position + #data
      end

      local function run_command_in_split(command)
        if type(command) ~= "string" or command == "" then
          vim.notify("ruby-lsp: no command to run", vim.log.levels.WARN)
          return
        end
        ensure_output_buf(command)
        ensure_output_win()
        append_position = 2

        local job_id = vim.fn.jobstart(command, {
          on_stdout = display_command_output,
          on_stderr = display_command_output,
          on_exit = function()
            if output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr) then
              vim.bo[output_bufnr].modifiable = false
            end
          end,
          stdout_buffered = false,
          stderr_buffered = false,
        })

        if job_id <= 0 then
          vim.notify("ruby-lsp: failed to start command: " .. command, vim.log.levels.ERROR)
        end
      end

      local function edit_file(uri)
        if not uri then
          return
        end
        local line = tonumber(uri:match "#L(%d+)" or 1) or 1
        local path = uri:gsub("^file://", ""):gsub("#L%d+", "")
        vim.cmd(string.format("edit +%d %s", line, vim.fn.fnameescape(path)))
      end

      local function open_file_command(command)
        local arg = command.arguments and command.arguments[1]
        if type(arg) == "string" then
          return edit_file(arg)
        end
        if type(arg) ~= "table" or vim.tbl_isempty(arg) then
          vim.notify("ruby-lsp: openFile missing arguments", vim.log.levels.WARN)
          return
        end
        if #arg == 1 then
          return edit_file(arg[1])
        end
        vim.ui.select(arg, {
          prompt = "Select a file to jump to",
          format_item = function(uri)
            return uri:match "^.+/(.+)$" or uri
          end,
        }, edit_file)
      end

      local function run_test_command(command)
        local args = command.arguments or {}
        local cmd = args[3] or args[1]
        run_command_in_split(cmd)
      end

      local function run_task_command(command)
        local args = command.arguments or {}
        run_command_in_split(args[1])
      end

      local function run_rspec_command(command)
        local args = command.arguments or {}
        run_command_in_split(args[1])
      end

      local function setup_ruby_lsp_codelens()
        if ruby_lsp_codelens_setup_done then
          return
        end
        ruby_lsp_codelens_setup_done = true

        local original_handler = vim.lsp.codelens.on_codelens
        local supported = {
          ["rubyLsp.runTest"] = true,
          ["rubyLsp.runTask"] = true,
          ["rubyLsp.openFile"] = true,
        }

        ---@diagnostic disable-next-line: duplicate-set-field
        vim.lsp.codelens.on_codelens = function(err, result, ctx)
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          if not client or client.name ~= "ruby_lsp" then
            return original_handler(err, result, ctx)
          end

          local filtered = vim.tbl_filter(function(lens)
            local cmd = lens.command and lens.command.command
            return cmd and (supported[cmd] or cmd:match "^rubyLsp%.rspec")
          end, result or {})

          return original_handler(err, filtered, ctx)
        end

        vim.lsp.commands["rubyLsp.runTest"] = run_test_command
        vim.lsp.commands["rubyLsp.runTask"] = run_task_command
        vim.lsp.commands["rubyLsp.openFile"] = open_file_command
        vim.lsp.commands["rubyLsp.rspecRunExample"] = run_rspec_command
        vim.lsp.commands["rubyLsp.rspecRunFile"] = run_rspec_command
        vim.lsp.commands["rubyLsp.rspecRunDirectory"] = run_rspec_command
        vim.lsp.commands["rubyLsp.rspecRunAll"] = run_rspec_command
      end

      setup_ruby_lsp_codelens()

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

          -- Find references for the word under your cursor.
          map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

          local function client_supports_method(client, method, bufnr)
            return client:supports_method(method, bufnr)
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, "[T]oggle Inlay [H]ints")
          end

          -- Show and run code lenses when supported (e.g. ruby-lsp and ruby-lsp-rails)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
            local codelens_augroup = vim.api.nvim_create_augroup("kickstart-lsp-codelens-" .. event.buf, { clear = true })
            local refresh_codelens = function(bufnr)
              vim.lsp.codelens.refresh { bufnr = bufnr }
            end

            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = event.buf,
              group = codelens_augroup,
              callback = function()
                refresh_codelens(event.buf)
              end,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              buffer = event.buf,
              group = codelens_augroup,
              callback = function(event2)
                vim.api.nvim_clear_autocmds { group = codelens_augroup, buffer = event2.buf }
              end,
            })

            refresh_codelens(event.buf)
            map("<leader>cr", function()
              refresh_codelens(event.buf)
            end, "[C]ode Lens [R]efresh")
            map("<leader>cl", vim.lsp.codelens.run, "[C]ode [L]ens run")
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      -- NOTE: The following line is now commented as blink.cmp extends capabilites by default from its internal code:
      -- https://github.com/Saghen/blink.cmp/blob/102db2f5996a46818661845cf283484870b60450/plugin/blink-cmp.lua
      -- It has been left here as a comment for educational purposes (as the predecessor completion plugin required this explicit step).
      --
      -- local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Language servers can broadly be installed in the following ways:
      --  1) via the mason package manager; or
      --  2) via your system's package manager; or
      --  3) via a release binary from a language server's repo that's accessible somewhere on your system.

      -- The servers table comprises of the following sub-tables:
      -- 1. mason
      -- 2. others
      -- Both these tables have an identical structure of language server names as keys and
      -- a table of language server configuration as values.
      ---@class LspServersConfig
      ---@field mason table<string, vim.lsp.Config>
      ---@field others table<string, vim.lsp.Config>
      local servers = {
        --  Add any additional override configuration in any of the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        --
        --  Feel free to add/remove any LSPs here that you want to install via Mason. They will automatically be installed and setup.
        mason = {
          -- clangd = {},
          -- gopls = {},
          -- pyright = {},
          -- rust_analyzer = {},
          -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
          --
          -- Some languages (like typescript) have entire language plugins that can be useful:
          --    https://github.com/pmizio/typescript-tools.nvim
          --
          -- But for many setups, the LSP (`ts_ls`) will work just fine
          -- ts_ls = {},
          --
          codebook = {},
          eslint = {},
          lua_ls = {
            -- cmd = { ... },
            -- filetypes = { ... },
            -- capabilities = {},
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { 'missing-fields' } },
              },
            },
          },
          ruby_lsp = {
            cmd = { vim.fn.expand "~/.rbenv/shims/ruby-lsp" },
            init_option = {
              formatter = "rubocop",
              linters = { "rubocop" },
              enabledFeatures = {
                codeLens = true,
              },
              addonSettings = {
                ["Ruby LSP Rails"] = {
                  enablePendingMigrationsPrompt = false,
                },
                ["Ruby LSP RSpec"] = {
                  rspecCommand = "rspec -f d",
                },
              },
            },
          },
          stylelint_lsp = {
            settings = {
              stylelintplus = {
                -- see available options in stylelint-lsp documentation
                autoFixOnFormat = true, -- automatically apply fixes in response to format requests.
                autoFixOnSave = true, -- automatically apply fixes on save.
              },
            },
          },
        },
        -- This table contains config for all language servers that are *not* installed via Mason.
        -- Structure is identical to the mason table from above.
        others = {
          -- dartls = {},
          coffeesense = {
            filetypes = { "coffee", "coffeescript" },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local mason_packages = vim.tbl_keys(servers.mason or {})
      vim.list_extend(mason_packages, {
        "coffeesense-language-server",
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup { ensure_installed = mason_packages }

      -- Either merge all additional server configs from the `servers.mason` and `servers.others` tables
      -- to the default language server configs as provided by nvim-lspconfig or
      -- define a custom server config that's unavailable on nvim-lspconfig.
      for server, config in pairs(vim.tbl_extend("keep", servers.mason, servers.others)) do
        if not vim.tbl_isempty(config) then
          vim.lsp.config(server, config)
        end
      end

      -- After configuring our language servers, we now enable them
      require("mason-lspconfig").setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_enable = ensure_installed, -- automatically run vim.lsp.enable() for all servers that are installed via Mason
      }

      -- Manually run vim.lsp.enable for all language servers that are *not* installed via Mason
      if not vim.tbl_isempty(servers.others) then
        vim.lsp.enable(vim.tbl_keys(servers.others))
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
