return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diagnostics', 'diff' },
        lualine_c = { 'filename' },
        lualine_x = { 'filetype' },
        lualine_y = { 'location' },
        lualine_z = {},
      },
    },
  },
  {
    'stevearc/dressing.nvim',
    opts = {},
    config = function()
      require('dressing').setup {
        select = {
          get_config = function(opts)
            if opts.kind == 'codeaction' then
              return {
                backend = 'nui',
                nui = {
                  relative = 'cursor',
                  max_width = 40,
                },
              }
            end
          end,
        },
      }
    end,
  },
}
