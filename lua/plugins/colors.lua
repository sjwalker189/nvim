local dark_theme = 'sora' --'north-sea' --'rose-pine' --'catppuccin'
local light_theme = 'rose-pine' -- 'modus-operandi'
local gsettings_key = 'org.gnome.desktop.interface color-scheme'

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

local function switch_colorscheme()
  vim.cmd.highlight 'clear'
  hl_undercurl()
  if vim.o.background == 'dark' then
    vim.cmd.colorscheme(dark_theme)
  else
    vim.cmd.colorscheme(light_theme)
  end
end

return {
  -- {
  --   'savq/melange-nvim',
  --   lazy = false,
  --   priority = 1000,
  --   init = function()
  --     vim.opt.termguicolors = true
  --     vim.cmd.colorscheme 'melange'
  --
  --     -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#333333' })
  --     -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#aaaaaa' })
  --
  --     local hl_groups = {
  --       'DiagnosticUnderlineError',
  --       'DiagnosticUnderlineWarn',
  --       'DiagnosticUnderlineInfo',
  --       'DiagnosticUnderlineHint',
  --       'DiagnosticUnderlineOk',
  --     }
  --
  --     for _, hl in ipairs(hl_groups) do
  --       vim.cmd.highlight(hl .. ' gui=undercurl')
  --     end
  --   end,
  -- },
  --
  --
  {
    'tjdevries/colorbuddy.nvim',
    lazy = false,
    priority = 1000,
    dependencies = {
      { 'rose-pine/neovim', name = 'rose-pine' },
      'terkelg/north-sea.nvim',
      'Aejkatappaja/sora',
    },
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      --
      local palette = require 'rose-pine.palette'

      require('rose-pine').setup {
        variant = 'auto', -- auto, main, moon, or dawn
        dark_variant = 'main', -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_highlights = false, -- Improve compatibility for previous versions of Neovim
          migrations = true, -- Handle deprecated options automatically
        },

        styles = {
          bold = false,
          italic = false,
          transparency = false,
        },

        groups = {
          border = 'muted',
          link = 'iris',
          panel = 'surface',

          error = 'love',
          hint = 'iris',
          info = 'foam',
          note = 'pine',
          todo = 'rose',
          warn = 'gold',

          git_add = 'foam',
          git_change = 'rose',
          git_delete = 'love',
          git_dirty = 'rose',
          git_ignore = 'muted',
          git_merge = 'iris',
          git_rename = 'pine',
          git_stage = 'iris',
          git_text = 'rose',
          git_untracked = 'subtle',

          h1 = 'iris',
          h2 = 'foam',
          h3 = 'rose',
          h4 = 'gold',
          h5 = 'pine',
          h6 = 'foam',
        },

        palette = {
          main = {
            pine = '#47869e',
          },

          dawn = {
            base = '#fbfaf9',
            gold = '#d48516',
            rose = '#cb5d57',
          },
        },

        -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#333333' })
        -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#aaaaaa' })

        -- NOTE: Highlight groups are extended (merged) by default. Disable this
        -- per group via `inherit = false`
        highlight_groups = {
          -- Comment = { fg = "foam" },
          -- StatusLine = { fg = "love", bg = "love", blend = 15 },
          -- VertSplit = { fg = "muted", bg = "muted" },
          -- Visual = { fg = "base", bg = "text", inherit = false },
          -- StatusLine = { fg = 'rose', bg = 'iris', blend = 10 },
          -- StatusLineNC = { fg = 'subtle', bg = 'surface' },
          --
          SnapBorder = { fg = 'muted' },
        },

        before_highlight = function(group, highlight, palette)
          hl_undercurl()
          -- Disable all undercurls
          -- if highlight.undercurl then
          --     highlight.undercurl = false
          -- end
          --
          -- Change palette colour
          -- if highlight.fg == palette.pine then
          --     highlight.fg = palette.foam
          -- end
        end,
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
  },
}
