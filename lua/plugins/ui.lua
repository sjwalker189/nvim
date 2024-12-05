local icons = require('base').icons
local colors = require('base').colors

return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        component_separators = '|',
        section_separators = '',
        globalstatus = true,
        theme = {
          normal = {
            a = { fg = colors.green },
            b = {},
            c = {},
            x = {},
            y = {},
            z = {},
          },
          visual = {
            a = { fg = colors.purple },
          },
          insert = {
            a = { fg = colors.blue },
          },
          replace = {
            a = { fg = colors.red },
          },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          'diff',
          {
            'diagnostics',
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        },
        lualine_c = {
          { 'filename', path = 1, separator = '', padding = { left = 1, right = 0 } },
        },
        lualine_x = {},
        lualine_y = {
          'location',
        },
        lualine_z = {},
      },
    },
  },
  {
    'stevearc/dressing.nvim',
    opts = {},
    config = function()
      require('dressing').setup {
        input = {
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
        },
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
