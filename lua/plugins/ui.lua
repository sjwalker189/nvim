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
            a = { fg = colors.aqua, bg = colors.aqua_dim },
            b = {},
            c = {
              bg = colors.black_bright,
            },
            x = {},
            y = {},
            z = {},
          },
          visual = {
            a = { fg = colors.violet, bg = colors.violet_dim },
          },
          insert = {
            a = { fg = colors.pink, bg = colors.pink_dim },
          },
          replace = {
            a = { fg = colors.red, bg = colors.red_dim },
          },
          command = {
            a = {
              fg = colors.orange,
              bg = colors.orange_dim,
            },
          },
          inactive = {
            a = {
              fg = colors.white,
              bg = colors.stone,
            },
          },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'branch', icon = icons.git.commit },
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
          { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
          { 'filename', path = 1, separator = '', padding = { left = 0, right = 0 } },
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
                  -- relative = 'cursor',
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
