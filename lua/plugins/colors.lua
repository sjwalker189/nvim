return {
  {

    'webhooked/kanso.nvim',
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = 'light'
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'kanso-pearl'

      local colors = require('kanso.colors').setup()
      local palette_colors = colors.palette
      -- local theme_colors = colors.theme

      vim.api.nvim_set_hl(0, 'SnapBorder', { fg = palette_colors.gray5 })

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
