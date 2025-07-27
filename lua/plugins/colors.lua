return {
  {

    'projekt0n/github-nvim-theme',
    lazy = false,
    priority = 1000,
    init = function()
      local palette = require('github-theme.palette').load 'github_light_default'
      require('github-theme').setup {
        options = {
          transparent = true,
          hide_nc_statusline = false,
          hide_end_of_buffer = false,
          -- inverse = {
          --   match_paren = true,
          --   visual = true,
          --   search = true,
          -- },
        },
        groups = {
          all = {
            ['@label.jsonc'] = { link = '@label.json' },
          },
          github_light_default = {
            StatusLine = { bg = palette.bg1 },
          },
        },
      }

      vim.o.background = 'dark'
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'github_light_default'

      vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#cccccc' })

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
