return {
  {
    'camspiers/luarocks',
    opts = { rocks = { 'fzy' } },
  },
  {
    'camspiers/snap',
    dependencies = { 'camspiers/luarocks' },
    config = function()
      local snap = require 'snap'

      local defaults = { prompt = '', suffix = '»' }
      local file = snap.config.file:with(defaults)
      local vimgrep = snap.config.vimgrep:with(vim.tbl_extend('force', defaults, {
        limit = 20000,
      }))

      snap.maps {
        {
          '<leader>ff',
          file { producer = 'ripgrep.file', args = { '--hidden', '--iglob', '!.git/*' } },
          command = 'files',
        },
        { '<leader>fb', file { producer = 'vim.buffer' }, { command = 'buffers' } },
        { '<leader>fr', file { producer = 'vim.oldfile' }, { command = 'oldfiles' } },
        { '<leader>fg', vimgrep {}, { command = 'grep' } },
        { '<leader>fw', vimgrep { filter_with = 'cword' }, { command = 'currentwordgrep' } },
      }

      -- Theme
      vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#5B6078' })
    end,
  },
}
