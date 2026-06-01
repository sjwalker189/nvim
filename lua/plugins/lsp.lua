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
      local is_deno_project = util.root_pattern { 'deno.json', 'deno.jsonc' }

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

        html = {},
        cssls = {},
        tailwindcss = {
          filetypes = { 'templ', 'javascript', 'typescript', 'react', 'vue', 'html' },
          init_options = { userLanguages = { templ = 'html' } },
        },
        ts_ls = {
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
          root_markers = { 'package.json', 'tsconfig.json' },
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
          root_markers = { 'package.json', 'tsconfig.json' },
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

        eslint = {
          root_markers = { 'eslint.config.js', 'eslint.config.ts', 'eslint.config.json', '.eslintrc' },
        },

        intelephense = {
          root_markers = { 'composer.json' },
        },
      }

      local ensure_installed = vim.tbl_keys(servers)

      require('mason-lspconfig').setup {
        automatic_enable = { exclude = { 'rust_analyzer' } },
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

      -- vim.lsp.config('phpantom', {
      --   cmd = { 'phpantom_lsp' },
      --   filetypes = { 'php' },
      --   root_markers = { 'composer.json', '.git' },
      -- })
      -- vim.lsp.enable 'phpantom'
      --
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
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = 'clippy' },
              cargo = { allFeatures = true },
              inlayHints = {
                closureReturnTypeHints = { enable = 'always' },
                lifetimeElisionHints = { enable = 'always', useParameterNames = true },
              },
            },
          },
          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr }
            -- Override generic LSP maps with Rust-specific equivalents
            vim.keymap.set('n', 'K', function() vim.cmd.RustLsp { 'hover', 'actions' } end, opts)
            vim.keymap.set({ 'n', 'v', 'i', 'x' }, '<C-.>', function() vim.cmd.RustLsp 'codeAction' end, opts)
            vim.keymap.set({ 'n', 'v', 'i', 'x' }, '<F3>', function() vim.cmd.RustLsp 'codeAction' end, opts)
            -- Rust-specific extras
            vim.keymap.set('n', '<leader>re', function() vim.cmd.RustLsp 'expandMacro' end, opts)
            vim.keymap.set('n', '<leader>rr', function() vim.cmd.RustLsp 'runnables' end, opts)
            vim.keymap.set('n', '<leader>rt', function() vim.cmd.RustLsp 'testables' end, opts)
            vim.keymap.set('n', '<leader>rod', function() vim.cmd.RustLsp 'openDocs' end, opts)
          end,
        },
      }
    end,
  },
}
