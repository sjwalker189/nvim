return {
  src = {
    { src = 'https://github.com/stevearc/conform.nvim' },
    { src = 'https://github.com/mfussenegger/nvim-lint' },
  },
  setup = function()
    require('conform').setup {
      -- PHP (pint) is slow, so format it asynchronously *after* the write to
      -- keep saving snappy; every other filetype formats synchronously before
      -- save as usual. The two hooks are mutually exclusive per buffer.
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == 'php' then
          return nil
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      format_after_save = function(bufnr)
        if vim.bo[bufnr].filetype == 'php' then
          return { lsp_format = 'fallback' }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        typescript = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        vue = { 'oxfmt' },
        astro = { 'oxfmt' },
        go = { 'goimports', 'gofmt' },
        php = { 'pint', lsp_format = 'never' },
      },
      formatters = {
        shfmt = {
          prepend_args = { '-i', '2' },
        },
      },
    }

    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.keymap.set('', '<S-C-i>', function()
      require('conform').format {
        async = true,
        lsp_format = 'fallback',
        stop_after_first = true,
      }
    end, { desc = 'Format buffer' })

    require('lint').linters_by_ft = {
      php = { 'phpstan' },
      -- vue = { 'eslint_d' },
    }
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
