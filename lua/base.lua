local M = {}

M.icons = {
  misc = {
    dots = '󰇘',
  },
  ft = {
    octo = '',
  },
  dap = {
    Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
    Breakpoint = ' ',
    BreakpointCondition = ' ',
    BreakpointRejected = { ' ', 'DiagnosticError' },
    LogPoint = '.>',
  },
  diagnostics = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
  },
  git = {
    commit = '',
    added = ' ',
    modified = ' ',
    removed = ' ',
  },
  kinds = {
    Array = ' ',
    Boolean = '󰨙 ',
    Class = ' ',
    Codeium = '󰘦 ',
    Color = ' ',
    Control = ' ',
    Collapsed = ' ',
    Constant = '󰏿 ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = '󰊕 ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = '󰊕 ',
    Module = ' ',
    Namespace = '󰦮 ',
    Null = ' ',
    Number = '󰎠 ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = ' ',
    String = ' ',
    Struct = '󰆼 ',
    Supermaven = ' ',
    TabNine = '󰏚 ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = '󰀫 ',
  },
}

--
-- TODO: cleanup this mess
--
M.colors = {
  fg = '#D6D6D6',
  bg = '#121317',

  superblack = '#09090B',
  black = '#121317',
  black_bright = '#1B1C22',

  stone = '#576a6e',

  superwhite = '#E0E0E0',
  softwhite = '#ebdbb2',
  white = '#D6D6D6',

  red = '#cc6666',
  red_dim = '#1F0A0A',

  -- pink = '#fef601', -- yellow
  pink = '#C08497',
  pink_dim = '#1B0E12',

  green = '#99cc99',
  yellow = '#fde68a',

  blue = '#81a2be',
  blue_dim = '#151F28',

  aqua = '#8ec07c', -- lime green
  aqua_dim = '#111C0D',

  cyan = '#8abeb7',
  purple = '#8e6fbd',

  violet = '#b294bb',
  violet_dim = '#171019',

  orange = '#de935f',
  orange_dim = '#331B0A',

  brown = '#a3685a',
  seagreen = '#698b69',
  turquoise = '#698b69',

  red_bright = '#D17575',
  green_bright = '#AED6AE',
  yellow_bright = '#F6FE5D',
  blue_bright = '#A1B9CE',
  purple_bright = '#A78FCC',
  cyan_bright = '#A3CCC7',
  white_bright = 'silver',
}

return M
