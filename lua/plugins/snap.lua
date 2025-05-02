-- List of project specific ignore paths for directories that
-- are not excluded from source control but that I dont care about
local ignore_paths = {
  ['aviat/provision-plus'] = {
    '!.idea/*',
    '!client/*',
    '!components/*',
    '!server/public/*',
    '!server/obfuscate/*',
    '!server/coverage/*',
    '!server/report/assets/js/vendor/*',
    '!server/report/assets/css/vendor/*',
    '!deployment/*',
  },
}

return {
  {
    'camspiers/luarocks',
    opts = { rocks = { 'fzy' } },
  },
  {
    'camspiers/snap',
    enabled = false,
    dependencies = { 'camspiers/luarocks' },
    config = function()
      local snap = require 'snap'

      local file = snap.config.file:with {
        prompt = '',
        suffix = 'Files »',
      }

      local vimgrep = snap.config.vimgrep:with {
        prompt = '',
        suffix = 'Grep »',
        limit = 20000,
      }

      local cwd = vim.loop.cwd()

      local search_defaults = {
        '--hidden',
        '--iglob',
        '!.git/*',
        '--iglob',
        '!node_modules/*',
      }

      local search_patterns = vim.tbl_extend('force', search_defaults, {})

      -- Apply any custom ignore path rules defined for the current directory
      for path, patterns in pairs(ignore_paths) do
        if cwd:sub(-#path) then
          for _, pattern in pairs(patterns) do
            table.insert(search_patterns, '--iglob')
            table.insert(search_patterns, pattern)
          end
        end
      end

      snap.maps {
        {
          '<leader>ff',
          file { producer = 'ripgrep.file', args = search_patterns },
          command = 'files',
        },
        { '<leader>fg', vimgrep { producer = 'ripgrep.vimgrep', args = search_patterns }, { command = 'grep' } },
        { '<leader>fb', file { producer = 'vim.buffer' }, { command = 'buffers' } },
        { '<leader>fr', file { producer = 'vim.oldfile' }, { command = 'oldfiles' } },
        { '<leader>fw', vimgrep { filter_with = 'cword' }, { command = 'currentwordgrep' } },

        -- Project wide search without ignored paths included
        {
          '<leader>fpf',
          file { producer = 'ripgrep.file', args = search_defaults },
          command = 'files',
        },
        { '<leader>fpg', vimgrep { producer = 'ripgrep.vimgrep', args = search_defaults }, { command = 'grep' } },
      }

      -- Theme
      vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#363646' })
    end,
  },
}
