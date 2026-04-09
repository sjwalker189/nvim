return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<S-C-i>',
        function()
          require('conform').format {
            async = true,
            lsp_fallback = true,
            stop_after_first = true,
          }
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'deno', 'biome', 'prettierd' },
        javascriptreact = { 'deno', 'biome', 'prettierd' },
        typescript = { 'deno', 'biome', 'prettierd' },
        typescriptreact = { 'deno', 'biome', 'prettierd' },
        vue = { 'biome', 'prettierd' },
        astro = { 'prettierd' },
        php = { 'pint' },
      },
      formatters = {
        shfmt = {
          prepend_args = { '-i', '2' },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  {
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = {
        php = { 'phpstan' },
        vue = { 'eslint' },
      }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
  },
}
