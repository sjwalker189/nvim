return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = {} },
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
    },
    event = 'VeryLazy',
    config = function()
      local lsp = require 'lspconfig'
      local servers = {
        lua_ls = {},
        bashls = {},
        html = {},
        cssls = {},
        tailwindcss = {
          filetypes = { 'templ', 'javascript', 'typescript', 'react', 'vue', 'html' },
          init_options = { userLanguages = { templ = 'html' } },
        },
        vue_ls = {
          filetypes = { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'react', 'vue' },
          init_options = {
            vue = {
              hybridMode = false,
            },
          },
        },
        gopls = {},
        templ = function()
          vim.filetype.add {
            extension = {
              templ = 'templ',
            },
          }
          return {
            cmd = { 'templ', 'lsp' },
            filetypes = { 'templ' },
            root_dir = lsp.util.root_pattern('go.mod', '.git'),
            settings = {},
          }
        end,
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      for name, opts in pairs(servers) do
        vim.lsp.enable(name)
        if type(opts) == 'function' then
          vim.lsp.config(name, opts())
        else
          vim.lsp.config(name, opts)
        end
      end
    end,
  },

  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'j-hui/fidget.nvim',
      {
        'mfussenegger/nvim-dap',
        config = function(self, opts)
          -- Debug settings if you're using nvim-dap
          local dap = require 'dap'

          dap.configurations.scala = {
            {
              type = 'scala',
              request = 'launch',
              name = 'RunOrTest',
              metals = {
                runType = 'runOrTestFile',
                --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
              },
            },
            {
              type = 'scala',
              request = 'launch',
              name = 'Test Target',
              metals = {
                runType = 'testTarget',
              },
            },
          }
        end,
      },
    },
    ft = { 'scala', 'sbt', 'java' },
    opts = function()
      local map = vim.keymap.set
      local metals_config = require('metals').bare_config()

      metals_config.on_attach = function(client, bufnr)
        require('metals').setup_dap()

        map('n', '<leader>ws', function()
          require('metals').hover_worksheet()
        end)

        -- all workspace diagnostics
        map('n', '<leader>aa', vim.diagnostic.setqflist)

        -- all workspace errors
        map('n', '<leader>ae', function()
          vim.diagnostic.setqflist { severity = 'E' }
        end)

        -- all workspace warnings
        map('n', '<leader>aw', function()
          vim.diagnostic.setqflist { severity = 'W' }
        end)

        -- buffer diagnostics only
        map('n', '<leader>d', vim.diagnostic.setloclist)

        map('n', '[c', function()
          vim.diagnostic.goto_prev { wrap = false }
        end)

        map('n', ']c', function()
          vim.diagnostic.goto_next { wrap = false }
        end)

        -- Example mappings for usage with nvim-dap. If you don't use that, you can
        -- skip these
        map('n', '<leader>dc', function()
          require('dap').continue()
        end)

        map('n', '<leader>dr', function()
          require('dap').repl.toggle()
        end)

        map('n', '<leader>dK', function()
          require('dap.ui.widgets').hover()
        end)

        map('n', '<leader>dt', function()
          require('dap').toggle_breakpoint()
        end)

        map('n', '<leader>dso', function()
          require('dap').step_over()
        end)

        map('n', '<leader>dsi', function()
          require('dap').step_into()
        end)

        map('n', '<leader>dl', function()
          require('dap').run_last()
        end)
      end

      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
      }

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        group = nvim_metals_group,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,
      })
    end,
  },
}
