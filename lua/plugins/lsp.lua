return {
  {
    'williamboman/mason.nvim',
    dependencies = {
      { 'williamboman/mason-lspconfig.nvim' },
      { 'neovim/nvim-lspconfig' },
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      local lsp = require 'lspconfig'

      require('mason').setup()
      require('mason-lspconfig').setup {
        automatic_installation = true,
        inlay_hints = {
          enabled = false, -- I hate these so much
        },
        ensure_installed = {
          'lua_ls',
          'bashls',
          'html',
          'cssls',
          'denols',
          'ts_ls',
          'gopls',
          'templ',
          'tailwindcss',
        },
        handlers = {
          -- Fallback lsp setup handler
          function(server_name)
            lsp[server_name].setup {}
          end,

          templ = function()
            vim.filetype.add {
              extension = {
                templ = 'templ',
              },
            }
            lsp.templ.setup {
              cmd = { 'templ', 'lsp' },
              filetypes = { 'templ' },
              root_dir = lsp.util.root_pattern('go.mod', '.git'),
              settings = {},
            }
          end,

          tailwindcss = function()
            lsp.tailwindcss.setup {
              filetypes = { 'templ', 'javascript', 'typescript', 'react', 'vue', 'html' },
              init_options = { userLanguages = { templ = 'html' } },
            }
          end,

          denols = function()
            lsp.denols.setup {
              root_dir = lsp.util.root_pattern('deno.json', 'deno.jsonc'),
            }
          end,

          ts_ls = function()
            lsp.ts_ls.setup {
              root_dir = lsp.util.root_pattern 'package.json',
              single_file_support = false,
              filetypes = { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'react', 'vue' },
              init_options = {
                plugins = {
                  -- Vue.js typescript support
                  {
                    name = '@vue/typescript-plugin',
                    location = vim.fn.stdpath 'data'
                      .. '/mason/packages/vue-language-server/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin',
                    languages = { 'javascript', 'typescript', 'vue' },
                  },
                },
              },
            }
          end,
        },
      }
    end,
  },
}
