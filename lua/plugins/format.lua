local typescript_formatters = {
  'prettierd',
  'prettier',
  stop_after_first = true,
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = 'prettierd', 'prettier' },
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<S-C-i>',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      format_on_save = { timeout_ms = 200, lsp_fallback = true },
      formatters_by_ft = {
        lua = { 'stylua' },
        php = { { 'pint', 'php_cs_fixer', stop_after_first = true } },
        javascript = typescript_formatters,
        javascriptreact = typescript_formatters,
        typescript = typescript_formatters,
        typescriptreact = typescript_formatters,
        vue = typescript_formatters,
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
