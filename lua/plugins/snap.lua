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
  src = {
    { src = 'https://github.com/camspiers/luarocks' },
    { src = 'https://github.com/camspiers/snap' },
  },
  setup = function()
    -- Install the `fzy` rock (python3 + hererocks + luajit; builds on first
    -- run). pcall so a missing python3 / pending build doesn't break snap —
    -- the `filter` below just falls back to the bundled fzf consumer.
    pcall(function()
      require('luarocks').setup { rocks = { 'fzy' } }
    end)

    -- The bundled luarocks installs rocks into its default user tree
    -- (~/.luarocks), but luarocks.setup only puts its own .rocks tree on
    -- package.cpath — so `require('fzy')` misses the freshly installed rock.
    -- Ask the luarocks binary for its real path config (this avoids the
    -- luarocks.org manifest, which trips a LuaJIT constant limit) and append
    -- it. Only done when fzy isn't already loadable, to skip the subprocess.
    if not pcall(require, 'fzy') then
      pcall(function()
        local lr = require 'luarocks.paths'
        if vim.fn.executable(lr.luarocks) ~= 1 then
          return
        end
        local function lr_path(arg)
          local out = vim.system({ lr.luarocks, 'path', arg }):wait()
          return out.code == 0 and vim.trim(out.stdout) or ''
        end
        package.path = package.path .. ';' .. lr_path '--lr-path'
        package.cpath = package.cpath .. ';' .. lr_path '--lr-cpath'
      end)
    end

    local snap = require 'snap'
    local tbl = require 'snap.common.tbl'

    -- Prefer the fzy consumer when the luarocks `fzy` rock is available,
    -- otherwise fall back to the bundled fzf consumer. Used by the producers
    -- that aren't wrapped by snap.config.file/vimgrep (marks, git, etc.).
    local filter = pcall(require, 'fzy') and snap.get 'consumer.fzy' or snap.get 'consumer.fzf'

    -- Track the last picker config so it can be re-opened (resume search),
    -- and remember the in-progress filter so the resume restores the query.
    local run = snap.run
    local last_config = nil
    snap.run = function(config)
      last_config = config
      local function on_update(query)
        if config.on_update then
          config.on_update(query)
        end
        last_config.initial_filter = query
      end
      run(tbl.merge(config, { on_update = on_update }))
    end

    -- Route vim.ui.select (code actions, etc.) through snap.
    vim.ui.select = function(items, opts, on_choice)
      snap.run {
        prompt = opts.prompt or 'Select» ',
        producer = filter(function()
          local result = {}
          for index, value in ipairs(items) do
            local label = opts.format_item and opts.format_item(value) or value
            table.insert(result, snap.with_metas(label, { value = value, index = index }))
          end
          return result
        end),
        select = vim.schedule_wrap(function(selection)
          if selection == nil then
            return
          end
          on_choice(selection.value, selection.index)
        end),
      }
    end

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

      -- Resume the previous picker (restores the in-progress query).
      {
        '<leader>i',
        function()
          if last_config then
            snap.run(last_config)
          end
        end,
        { desc = 'Resume last search' },
      },

      -- Grep the current visual selection.
      { '<leader>fm', vimgrep { filter_with = 'selection' }, { modes = 'v', desc = 'Grep selection' } },

      -- Marks
      {
        '<leader>n',
        function()
          snap.run {
            producer = filter(snap.get 'producer.vim.marks'),
            select = snap.get('select.vim.mark').select,
            views = { snap.get 'preview.vim.mark' },
          }
        end,
        { desc = 'Search local marks' },
      },
      {
        '<leader>N',
        function()
          snap.run {
            producer = filter(snap.get 'producer.vim.globalmarks'),
            select = snap.get('select.vim.mark').select,
            views = { snap.get 'preview.vim.mark' },
          }
        end,
        { desc = 'Search global marks' },
      },

      -- Jumplist
      {
        '<leader>fj',
        function()
          snap.run {
            producer = filter(snap.get 'producer.vim.jumplist'),
            select = snap.get('select.jumplist').select,
            views = { snap.get 'preview.jumplist' },
          }
        end,
        { desc = 'Search in jumplist' },
      },

      -- Git files
      { '<leader>fG', file { producer = 'git.file' }, { command = 'git.files', desc = 'Git files' } },

      -- Git log: pick a commit, then choose an action on it.
      {
        '<leader>gl',
        function()
          snap.run {
            producer = filter(snap.get 'producer.git.log'),
            select = function(selection)
              snap.run {
                prompt = string.format("Action on commit '%s'?", selection.hash),
                suffix = '',
                producer = filter(function()
                  return { 'checkout', 'reset' }
                end),
                select = function(choice)
                  print(tostring(choice) .. ' : ' .. selection.hash)
                end,
                layout = function()
                  return snap.get('layout')['%bottom'](0.2, 0.1)
                end,
              }
            end,
            views = { snap.get 'preview.git.log' },
          }
        end,
        { desc = 'Search git log' },
      },

      -- Git branches (gitsigns owns <leader>gb, so these live under gB/gR).
      {
        '<leader>gB',
        function()
          snap.run {
            producer = filter(snap.get 'producer.git.branch.local'),
            select = snap.get('select.git').branch,
          }
        end,
        { desc = 'Search local git branches' },
      },
      {
        '<leader>gR',
        function()
          snap.run {
            producer = filter(snap.get 'producer.git.branch.remote'),
            select = function(selection)
              snap.run {
                producer = filter(function()
                  return { 'checkout', 'reset' }
                end),
                select = function(choice)
                  print(tostring(choice) .. ' : ' .. tostring(selection))
                end,
                layout = function()
                  return snap.get('layout')['%bottom'](0.2, 0.1)
                end,
              }
            end,
          }
        end,
        { desc = 'Search remote git branches' },
      },
    }

    -- vim.api.nvim_set_hl(0, 'SnapBorder', { fg = '#363646' })
  end,
}
