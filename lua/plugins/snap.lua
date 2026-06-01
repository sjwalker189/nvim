-- List of project specific ignore paths for directories that
-- are not excluded from source control but that I dont care about
local ignore_paths = {
  -- ['aviat/provision-plus'] = {
  --   '!.idea/*',
  --   --'!client/*',
  --   '!components/*',
  --   '!server/public/*',
  --   '!server/obfuscate/*',
  --   '!server/coverage/*',
  --   '!server/report/assets/js/vendor/*',
  --   '!server/report/assets/css/vendor/*',
  --   '!deployment/*',
  -- },
}

local function snap_directory_grep(snap)
  local fd_args = { '--type', 'd', '-H', '-E', '.git', '-E', 'node_modules', '-E', 'vendor' }
  local dir_picker = snap.config.file {
    prompt = 'Select Directory> ',
    producer = 'fd.file',
    args = fd_args,
    select = function(yield)
      -- 'yield' is an iterator in snap. Calling it gets the selected item.
      local dir = yield()

      -- Exit if the user pressed Escape
      if not dir then
        return
      end

      -- Step 2: Create the grep picker for the chosen directory
      local grep_picker = snap.config.vimgrep {
        prompt = 'Grep in ' .. dir .. '> ',
        -- Pass the directory path as an argument so ripgrep only searches there
        args = { dir },
      }

      grep_picker()
    end,
  }

  return dir_picker
end

local function insert_ignore_pattern(t, pattern)
  table.insert(t, '--iglob')
  table.insert(t, pattern)
end

return {
  {
    'sjwalker189/snap',
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

      local search_patterns = { '--hidden' }

      local search_defaults = {
        '!.git/*',
        '!node_modules/*',
        '!vendor/*',
      }

      for _, path in ipairs(search_defaults) do
        insert_ignore_pattern(search_patterns, path)
      end

      -- Apply any custom ignore path rules defined for the current directory
      for path, patterns in pairs(ignore_paths) do
        if cwd ~= nil and cwd ~= '' and cwd:sub(-#path) then
          for _, pattern in pairs(patterns) do
            insert_ignore_pattern(search_patterns, pattern)
          end
        end
      end

      snap.maps {
        { '<leader>fw', vimgrep { filter_with = 'cword' }, { command = 'currentwordgrep' } },
        {
          '<leader>ff',
          file {
            producer = 'ripgrep.file',
            args = search_patterns,
            command = 'files',
          },
        },
        { '<leader>fr', file { producer = 'vim.oldfile' }, { command = 'oldfiles' } },
        { '<leader>fg', vimgrep { producer = 'ripgrep.vimgrep', args = search_patterns }, { command = 'grep' } },
        { '<leader>fb', file { producer = 'vim.buffer' }, { command = 'buffers' } },
        {
          '<leader>fid',
          snap_directory_grep(snap),
          { desc = 'Grep in directory' },
        }, -- Find in dir
      }

      -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#363646' })
    end,
  },
}
