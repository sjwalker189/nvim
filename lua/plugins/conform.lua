---@type conform.FormatOpts
local format_opts = {
  async = true,
  lsp_fallback = true,
  stop_after_first = true,
}

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<S-C-i>',
        function()
          require('conform').format(format_opts)
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'deno_fmt' },
        javascriptreact = { 'deno_fmt' },
        typescript = { 'deno_fmt' },
        typescriptreact = { 'deno_fmt' },
        vue = { 'deno_fmt' },
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
