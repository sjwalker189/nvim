return {
  {
    'adalessa/laravel.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
    },
    cmd = { 'Laravel' },
    keys = {
      { '<leader>la', ':Laravel artisan<cr>', desc = 'Laravel Artisan' },
      { '<leader>lr', ':Laravel routes<cr>', desc = 'Laravel Routes' },
    },
    config = function()
      require('laravel').setup {
        features = {
          pickers = {
            provider = 'ui-select',
          },
        },
      }
    end,
  },
}
