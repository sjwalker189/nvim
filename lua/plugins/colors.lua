local dark_theme = 'kanso'
local light_theme = 'kanso'
local gsettings_key = 'org.gnome.desktop.interface color-scheme'

local function hl_undercurl()
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
end

-- nebula's default Visual highlight is a bright purple bg with a forced
-- near-white fg, which washes out selected text. Keep the purple hue but
-- dilute it ~30% into the background (like lowering its opacity), and drop
-- the forced fg so the underlying syntax colors stay readable.
local function hl_visual_selection()
  local bg = vim.o.background == 'dark' and '#352757' or '#ddc9f2'
  vim.api.nvim_set_hl(0, 'Visual', { bg = bg })
  vim.api.nvim_set_hl(0, 'VisualNOS', { bg = bg })
end

-- kanso defines WinSeparator with fg = bg_m3, which is the same colour as the
-- normal background in both ink and pearl, so split borders are invisible.
-- With laststatus=3 there is no per-window statusline either, leaving nothing
-- to mark the divide. Paint the separator in a mid-tone instead.
local function hl_win_separator()
  local fg = vim.o.background == 'dark' and '#4b4e57' or '#9f9f99'
  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = fg })
  vim.api.nvim_set_hl(0, 'VertSplit', { link = 'WinSeparator' })
end

local function update_colorscheme(scheme_value)
  local current_scheme = scheme_value
  if not current_scheme then
    local handle = io.popen('gsettings get ' .. gsettings_key)
    if handle then
      current_scheme = handle:read '*a'
      handle:close()
    end
  end

  -- Clean up the string output from gsettings (e.g., "'prefer-light'\n")
  if current_scheme then
    current_scheme = current_scheme:match "'(.-)'" or current_scheme:match '"(.+)"'
  end

  -- Apply the correct colorscheme based on the value
  if current_scheme == 'prefer-dark' or current_scheme == 'dark' then
    vim.cmd.highlight 'clear'
    vim.cmd.colorscheme(dark_theme)
  elseif current_scheme == 'prefer-light' or current_scheme == 'light' or current_scheme == 'default' then
    vim.cmd.highlight 'clear'
    vim.cmd.colorscheme(light_theme)
  end

  hl_undercurl()
  hl_visual_selection()
  hl_win_separator()
end

local function monitor_callback(_, data, _)
  if data and #data > 0 then
    local new_value_line = data[#data]
    local new_value = new_value_line:match ':(.*)'
    if new_value then
      update_colorscheme(new_value:trim())
    end
  end
end

local function start_gsettings_monitor()
  vim.fn.jobstart({
    'gsettings',
    'monitor',
    gsettings_key,
  }, {
    on_stdout = monitor_callback,
    stdout_buffered = true,
    -- Detach the job so it keeps running even if Neovim loses focus
    pty = true,
  })
end

local function switch_colorscheme()
  vim.cmd.highlight 'clear'
  if vim.o.background == 'dark' then
    vim.cmd.colorscheme(dark_theme)
  else
    vim.cmd.colorscheme(light_theme)
  end
  hl_undercurl()
  hl_visual_selection()
  hl_win_separator()
end

return {
  src = {
    { src = 'https://github.com/webhooked/kanso.nvim' },
  },
  setup = function()
    vim.opt.termguicolors = true

    require('kanso').setup {
      bold = false,
      italics = true,
      undercurl = true,
      terminalColors = true,
      background = {
        dark = 'ink',
        light = 'pearl',
      },
    }

    local theme_augroup = vim.api.nvim_create_augroup('ThemeSwitcher', { clear = true })

    vim.api.nvim_create_autocmd('OptionSet', {
      group = theme_augroup,
      pattern = 'background',
      callback = switch_colorscheme,
      nested = true,
    })

    switch_colorscheme()
    -- start_gsettings_monitor()
  end,
}
