return {
  src = {
    { src = 'https://github.com/editorconfig/editorconfig-vim' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/kevinhwang91/nvim-bqf' },
    { src = 'https://github.com/stevearc/stickybuf.nvim' },
    { src = 'https://github.com/AckslD/nvim-neoclip.lua' },
    { src = 'https://github.com/numToStr/Comment.nvim' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  },
  setup = function()
    require('bqf').setup {}
    require('stickybuf').setup {}
    require('neoclip').setup {}
    require('Comment').setup {}
    require('render-markdown').setup {}
    require('lualine').setup {
      globalstatus = true,
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'lsp_status', { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
    }
  end,
}
