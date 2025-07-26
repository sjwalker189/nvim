return {
  {
    'lunacookies/vim-colors-xcode',
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = 'dark'
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'xcodelight'

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
