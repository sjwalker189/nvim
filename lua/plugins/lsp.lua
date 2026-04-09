return {
  {
    'folke/neodev.nvim',
    config = function()
      require('neodev').setup {}
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = {} },
    },
    event = 'VeryLazy',
    config = function()
      local util = require 'lspconfig.util'
      local is_node_project = util.root_pattern 'package.json'
      local is_deno_project = util.root_pattern { 'deno.json', 'deno.jsonc' }
      local cancel_attach = function(predicate)
        return function(client, bufnr)
          if predicate(bufnr) then
            client.stop()
            return false
          end
        end
      end

      local vue_language_server_path = vim.fn.expand '$MASON/packages/vue-language-server'

      local servers = {
        bashls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                -- Add Neovim's runtime files for lsp completions
                library = vim.api.nvim_get_runtime_file('', true),
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },

        zls = {},
        html = {},
        cssls = {},
        tailwindcss = {
          filetypes = { 'templ', 'javascript', 'typescript', 'react', 'vue', 'html' },
          init_options = { userLanguages = { templ = 'html' } },
        },
        ts_ls = {
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = vue_language_server_path .. '/node_modules/@vue/language-server',
                languages = { 'vue' },
                configNamespace = 'typescript',
                enableForWorkspaceTypeScriptVersions = true,
              },
            },
            preferences = {
              importModuleSpecifierEnding = 'js',
              importModuleSpecifierPreference = 'shortest',
              includeCompletionsForImportStatements = true,
              includeCompletionsForModuleExports = true,
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
            },
          },
        },
        vue_ls = {
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
          init_options = {
            vue = {
              hybridMode = true,
            },
          },
        },
        astro = {},
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
            root_markers = { 'go.mod' },
            settings = {},
          }
        end,

        intelephense = {},
      }

      local ensure_installed = vim.tbl_keys(servers)

      require('mason-lspconfig').setup {
        automatic_enable = true,
        ensure_installed = ensure_installed,
      }

      for name, opts in pairs(servers) do
        vim.lsp.enable(name)
        if type(opts) == 'function' then
          vim.lsp.config(name, opts())
        else
          vim.lsp.config(name, opts)
        end
      end

      vim.lsp.config('biome', {
        on_attach = function(client, bufnr)
          if client.name == 'biome' and is_deno_project(bufnr) then
            client.stop()
            return false
          end
        end,
      })
    end,
  },

  {
    -- Rust
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    lazy = false, -- This plugin is already lazy
  },
}
