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
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                -- Add Neovim's runtime files
                library = vim.api.nvim_get_runtime_file('', true),
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
        ts_ls = {},
        bashls = {},
        html = {},
        cssls = {},
        tailwindcss = {
          filetypes = { 'templ', 'javascript', 'typescript', 'react', 'vue', 'html' },
          init_options = { userLanguages = { templ = 'html' } },
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
            root_markers = { 'go.mod' },
            settings = {},
          }
        end,
      }

      require('mason-lspconfig').setup {
        automatic_enable = true,
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
}
