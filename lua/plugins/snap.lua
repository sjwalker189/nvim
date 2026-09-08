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

-- Pick a directory under the project root, then grep inside it. `grep_in` builds
-- the second-stage producer; it's passed in so this shares the rooted ripgrep
-- wrapper defined in setup() rather than snap's own (see the note there).
local function snap_directory_grep(snap, grep_in)
  local fd_args = { '--type', 'd', '-H', '-E', '.git', '-E', 'node_modules', '-E', 'vendor' }

  return function()
    local root = require('project').root()

    snap.config.file {
      prompt = 'Select Directory> ',
      producer = 'fd.file',
      -- fd.file.args takes no cwd (unlike ripgrep's), so scope it with fd's own
      -- --search-path. An absolute search path also makes fd emit absolute
      -- results, which the grep below needs.
      args = vim.list_extend(vim.deepcopy(fd_args), { '--search-path', root }),
      select = function(yield)
        -- 'yield' is an iterator in snap. Calling it gets the selected item.
        local dir = yield()

        -- Exit if the user pressed Escape
        if not dir then
          return
        end

        -- `dir` is absolute (see --search-path above), so grep is rooted there.
        dir = tostring(dir):gsub('/$', '')
        snap.config.vimgrep {
          prompt = 'Grep in ' .. dir .. '> ',
          producer = grep_in(dir),
        }()
      end,
    }()
  end
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
        window = function()
          return {
            width = 0.5,
            height = 0.5,
          }
        end,
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

    local search_defaults = {
      '!.git/*',
      '!node_modules/*',
      '!vendor/*',
    }

    -- Built per invocation rather than once at startup, so the ignore rules track
    -- the buffer's project instead of wherever nvim happened to be launched.
    local function search_args(root)
      local search_patterns = { '--hidden' }

      for _, path in ipairs(search_defaults) do
        insert_ignore_pattern(search_patterns, path)
      end

      -- Apply any custom ignore path rules defined for the current project
      for path, patterns in pairs(ignore_paths) do
        if root ~= '' and root:sub(-#path) == path then
          for _, pattern in pairs(patterns) do
            insert_ignore_pattern(search_patterns, pattern)
          end
        end
      end

      return search_patterns
    end

    local project = require 'project'
    local snap_io = snap.get 'common.io'
    local snap_str = snap.get 'common.string'

    -- Snap's own ripgrep producers take a cwd, but passing one flips them into
    -- `absolute` mode -- and that branch is broken upstream: producer/ripgrep/
    -- general.lua binds `local string = snap.get("common.string")`, shadowing
    -- Lua's `string`, so `string.format` is nil and the producer coroutine dies
    -- silently with zero results. Reimplement the spawn loop here so the search
    -- can be rooted at the project and still return usable absolute paths.
    --
    -- `root` is resolved by the caller, before the coroutine starts: inside a
    -- producer, vim calls must go through snap.sync.
    local function rg_producer(root, args, with_filter)
      return function(request)
        local argv = vim.deepcopy(args)
        if with_filter then
          -- ripgrep wants the pattern last, after the flags.
          table.insert(argv, request.filter)
        end

        for data, err, cancel in snap_io.spawn('rg', argv, root) do
          if request.canceled() then
            cancel()
            coroutine.yield(nil)
          elseif err ~= '' then
            coroutine.yield(nil)
          elseif data == '' then
            snap.continue()
          else
            -- Prefix with the root so selections resolve regardless of cwd.
            coroutine.yield(vim.tbl_map(function(line)
              return root .. '/' .. line
            end, snap_str.split(data)))
          end
        end
      end
    end

    local function rg_files()
      local root = project.root()
      local args = { '--line-buffered', '--files' }
      vim.list_extend(args, search_args(root))
      return rg_producer(root, args, false)
    end

    local function rg_grep(root)
      root = root or project.root()
      local args = { '--line-buffered', '-M', '100', '--vimgrep' }
      vim.list_extend(args, search_args(root))
      return rg_producer(root, args, true)
    end

    -- producer.git.file.args accepts no cwd (and its body reads an undefined
    -- upvalue), so shell out directly. The listing is built here, at keypress
    -- time, rather than inside the producer: vim.system():wait() cannot run in
    -- snap's producer coroutine and silently yields nothing if you try.
    -- snap.config.file applies its own fuzzy consumer, so don't wrap in `filter`.
    local function git_files()
      local root = project.root()
      local out = vim.system({ 'git', '-C', root, 'ls-files', '--full-name' }):wait()
      local list = {}
      if out.code == 0 then
        list = vim.tbl_map(function(p)
          return root .. '/' .. p
        end, vim.split(vim.trim(out.stdout), '\n', { trimempty = true }))
      end
      return function()
        return list
      end
    end

    snap.maps {
      {
        '<leader>fw',
        function()
          vimgrep { producer = rg_grep(), filter_with = 'cword' }()
        end,
        { command = 'currentwordgrep' },
      },
      {
        '<leader>ff',
        function()
          file { producer = rg_files(), command = 'files' }()
        end,
      },
      { '<leader>fr', file { producer = 'vim.oldfile' }, { command = 'oldfiles' } },
      {
        '<leader>fg',
        function()
          vimgrep { producer = rg_grep() }()
        end,
        { command = 'grep' },
      },
      { '<leader>fb', file { producer = 'vim.buffer' }, { command = 'buffers' } },
      {
        '<leader>fid',
        snap_directory_grep(snap, rg_grep),
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
      {
        '<leader>fm',
        function()
          vimgrep { producer = rg_grep(), filter_with = 'selection' }()
        end,
        { modes = 'v', desc = 'Grep selection' },
      },

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
      {
        '<leader>fG',
        function()
          file { producer = git_files() }()
        end,
        { command = 'git.files', desc = 'Git files' },
      },

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
