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
        javascript = { 'deno', 'biome' },
        javascriptreact = { 'deno', 'biome' },
        typescript = { 'deno', 'biome' },
        typescriptreact = { 'deno', 'biome' },
        vue = { 'biome' },
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
}
