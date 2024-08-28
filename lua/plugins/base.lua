return {
  -- Base
  { 'folke/neodev.nvim', opts = {} },
  { 'editorconfig/editorconfig-vim' },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Code comments
  {
    'numToStr/Comment.nvim',
    opts = {},
    event = { 'BufReadPre', 'BufNewFile' },
  },

  -- quickfixlist
  { 'kevinhwang91/nvim-bqf' },
  { 'stevearc/stickybuf.nvim', opts = {} },

  {
    'AckslD/nvim-neoclip.lua',
    config = function()
      require('neoclip').setup()
    end,
  },
}
