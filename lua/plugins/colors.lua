return {
  {
    'savq/melange-nvim',
    lazy = false,
    priority = 1000,
    init = function()
      vim.opt.termguicolors = true
      -- vim.o.background = 'light'
      vim.cmd.colorscheme 'melange'

      -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#333333' })
      vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#aaaaaa' })

      local hl_groups = {
        'DiagnosticUnderlineError',
        'DiagnosticUnderlineWarn',
        'DiagnosticUnderlineInfo',
        'DiagnosticUnderlineHint',
        'DiagnosticUnderlineOk',
      }

      for _, hl in ipairs(hl_groups) do
        vim.cmd.highlight(hl .. ' gui=undercurl')
      end
    end,
  },
}
