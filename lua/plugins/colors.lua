return {
  {
    'tjdevries/colorbuddy.nvim',
    config = function()
      vim.cmd.colorscheme 'gruvbuddy'

      local colorbuddy = require 'colorbuddy'

      local Color = colorbuddy.Color
      local Group = colorbuddy.Group
      local c = colorbuddy.colors
      local g = colorbuddy.groups
      local s = colorbuddy.styles

      Color.new('black', '#000000')
      Color.new('white', '#f2e5bc')
      Color.new('red', '#cc6666')
      Color.new('pink', '#fef601')
      Color.new('green', '#99cc99')
      Color.new('yellow', '#fde68a')
      Color.new('blue', '#81a2be')
      Color.new('aqua', '#8ec07c')
      Color.new('cyan', '#8abeb7')
      Color.new('purple', '#8e6fbd')
      Color.new('violet', '#b294bb')
      Color.new('orange', '#de935f')
      Color.new('brown', '#a3685a')
      Color.new('seagreen', '#698b69')
      Color.new('turquoise', '#698b69')

      local background_string = '#121317'
      local comment_string = '#576a6e'

      Color.new('background', background_string)
      Color.new('gray0', background_string)
      Color.new('comment', comment_string)

      Group.new('@constant', c.orange, nil, s.none)

      Group.new('@function', c.yellow, g.Normal, g.Normal)
      Group.new('@function.bracket', c.gray3, g.Normal, g.Normal)

      Group.new('@keyword', c.violet, nil, s.none)
      Group.new('@keyword.faded', g.nontext.fg:light(), nil, s.none)

      Group.new('@property', c.blue)

      Group.new('@variable', c.superwhite, nil)
      Group.new('@variable.member', c.blue)
      Group.new('@variable.member.vue', c.violet, g.Normal)
      Group.new('@variable.builtin', c.purple:light():light(), g.Normal)

      Group.new('@tag.attribute', c.violet, g.Normal)
      Group.new('@tag.delimiter', c.blue:light())

      Group.new('@punctuation.bracket', c.gray4)
      Group.new('@punctuation.special.vue', g.variable)

      Group.new('Normal', c.superwhite, c.gray0)
      Group.new('Comment', c.comment, nil, s.italic)
      Group.new('CursorLine', nil, g.normal.bg:light(0.15))
      Group.new('CursorLineNr', c.white)
      Group.new('StatusLine', c.softwhite, c.background, nil)
      Group.new('WinSeparator', c.gray2)
      Group.new('NormalFloat', c.white)
      Group.new('Tooltip', c.red)

      vim.schedule(function()
        local hl_groups = { 'DiagnosticUnderlineError' }
        for _, hl in ipairs(hl_groups) do
          vim.cmd.highlight(hl .. ' gui=undercurl')
        end
      end)
    end,
  },
}
