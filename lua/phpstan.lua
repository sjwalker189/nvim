-- Whole-project phpstan, published as diagnostics across every affected file.
--
-- Per-file analysis (what nvim-lint does) cannot produce phpstan's project-level
-- errors: `ignore.unmatched` only exists once every path in phpstan.neon has been
-- analysed, so a baseline entry that no longer matches is invisible file-by-file.
-- This runs the project the way `composer test:types` does and fans the results
-- out to buffers, including files that aren't open yet.
--
-- A run is 10-25s on the larger apps, so it is always async and never blocks the
-- save. Saves arriving mid-run are coalesced into one follow-up run rather than
-- queueing up behind each other.
local project = require 'project'

local M = {}

local ns = vim.api.nvim_create_namespace 'phpstan'
local MARKERS = { 'phpstan.neon', 'phpstan.neon.dist', 'composer.json' }

---In-flight run per project root. `again` records saves that landed mid-run.
---@type table<string, { again: boolean }>
local running = {}

---Buffers published per project root, so the next run can clear what it no
---longer reports. Diagnostics are keyed by buffer, and a file whose errors are
---all fixed simply stops appearing in the JSON.
---@type table<string, integer[]>
local published = {}

---Last reported error count per root, for the statusline. lualine's own
---`diagnostics` component only counts the current buffer, and most of a project
---run's results land on buffers that aren't open.
---@type table<string, integer>
local totals = {}

local SPINNER = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local spinner = { timer = nil, frame = 1 }

---The statusline only repaints on lualine's own schedule, so an in-flight run
---drives the repaint itself; the timer exists only while phpstan is running.
local function sync_spinner()
  local active = next(running) ~= nil

  if active and not spinner.timer then
    spinner.timer = vim.uv.new_timer()
    spinner.timer:start(
      0,
      100,
      vim.schedule_wrap(function()
        spinner.frame = spinner.frame % #SPINNER + 1
        pcall(vim.cmd.redrawstatus)
      end)
    )
  elseif not active and spinner.timer then
    spinner.timer:stop()
    spinner.timer:close()
    spinner.timer = nil
    pcall(vim.cmd.redrawstatus)
  end
end

---@param root string
---@return boolean
function M.analysed(root)
  return published[root] ~= nil
end

---Roots with a run in flight.
---@return string[]
function M.running()
  return vim.tbl_keys(running)
end

---Statusline component: a spinner while analysing, then the project's error
---count. Empty once a run comes back clean, so the statusline stays quiet.
---@return string
function M.status()
  if next(running) then
    return SPINNER[spinner.frame] .. ' phpstan'
  end

  local count = 0
  for _, n in pairs(totals) do
    count = count + n
  end

  return count > 0 and ('phpstan ' .. count) or ''
end

---Whether `status()` has anything to show — for a lualine `cond`.
---@return boolean
function M.active()
  return M.status() ~= ''
end

---@param message string
---@param level integer
local function notify(message, level)
  vim.notify(message, level, { title = 'phpstan' })
end

---@param root string
---@param files table<string, { messages?: table[] }>
---@return integer count
local function publish(root, files)
  for _, bufnr in ipairs(published[root] or {}) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.diagnostic.reset(ns, bufnr)
    end
  end

  local buffers, count = {}, 0

  for file, entry in pairs(files) do
    local path = vim.fs.normalize(file)
    if not vim.startswith(path, '/') then
      path = root .. '/' .. path
    end

    -- Attaches to the buffer if the file is already open, and otherwise creates
    -- an unloaded one; the diagnostics show up when the file is later opened.
    local bufnr = vim.fn.bufadd(path)
    local diagnostics = {}

    for _, message in ipairs(entry.messages or {}) do
      -- Project-level errors (an unmatched baseline pattern, say) have no line.
      local lnum = type(message.line) == 'number' and message.line - 1 or 0
      if vim.api.nvim_buf_is_loaded(bufnr) then
        lnum = math.min(lnum, math.max(vim.api.nvim_buf_line_count(bufnr) - 1, 0))
      end

      table.insert(diagnostics, {
        lnum = math.max(lnum, 0),
        col = 0,
        message = message.message,
        source = 'phpstan',
        code = message.identifier,
        -- A stale baseline entry is housekeeping, not broken code.
        severity = message.identifier == 'ignore.unmatched' and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR,
      })
    end

    vim.diagnostic.set(ns, bufnr, diagnostics)
    table.insert(buffers, bufnr)
    count = count + #diagnostics
  end

  published[root] = buffers
  totals[root] = count
  return count
end

---Analyse the buffer's project.
---@param opts? { notify?: boolean, bufnr?: integer }
function M.analyse(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or 0

  local bin = project.find_bin('vendor/bin/phpstan', bufnr)
  local root = project.config_root(MARKERS, bufnr)
  if not bin or not root then
    if opts.notify then
      notify('no vendor/bin/phpstan above ' .. vim.api.nvim_buf_get_name(bufnr), vim.log.levels.WARN)
    end
    return
  end

  -- Saving repeatedly during a run would otherwise start a run per save.
  if running[root] then
    running[root].again = true
    if opts.notify then
      notify('already analysing; queued a re-run', vim.log.levels.INFO)
    end
    return
  end
  running[root] = { again = false }
  sync_spinner()

  if opts.notify then
    notify('analysing ' .. vim.fn.fnamemodify(root, ':~'), vim.log.levels.INFO)
  end

  local cmd = {
    bin,
    'analyse',
    '--error-format=json',
    '--no-progress',
    '--no-ansi',
    -- PHP's default 128M is not enough to boot larastan; matches composer test:types.
    '--memory-limit=-1',
  }

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local again = running[root].again
      running[root] = nil

      -- phpstan exits 1 whenever it reports anything, so the exit code says
      -- nothing about success. Non-JSON on stdout is what a real failure looks
      -- like: a missing config, a bad option, a crash before analysis.
      local ok, decoded = pcall(vim.json.decode, result.stdout or '')
      if not ok or type(decoded) ~= 'table' or type(decoded.files) ~= 'table' then
        local detail = vim.trim(result.stderr or '')
        if detail == '' then
          detail = vim.trim(result.stdout or '')
        end
        notify('failed: ' .. (vim.split(detail, '\n')[1] or 'no output'), vim.log.levels.ERROR)
      else
        local count = publish(root, decoded.files)

        -- Crashes that survive to a JSON response (a dead parallel worker, an
        -- unreadable config) land here rather than against any file.
        for _, message in ipairs(decoded.errors or {}) do
          notify(message, vim.log.levels.ERROR)
        end

        if opts.notify then
          notify(count == 0 and 'no errors' or count .. ' error(s) across ' .. #published[root] .. ' file(s)', vim.log.levels.INFO)
        end
      end

      -- A save that landed mid-run gets one follow-up, so results always reflect
      -- what is on disk. Ordered before the sync so the spinner doesn't blink.
      if again then
        M.analyse { bufnr = bufnr }
      end
      sync_spinner()
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('Phpstan', function()
    M.analyse { notify = true }
  end, { desc = 'phpstan: analyse the whole project' })

  -- .neon too: editing phpstan.neon or the baseline changes what every file
  -- reports, and those edits are exactly when the results matter.
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = { '*.php', '*.neon' },
    callback = function(args)
      M.analyse { bufnr = args.buf }
    end,
  })

  -- Opening a PHP file seeds the project's diagnostics once, so you get the full
  -- picture without having to save something first. Later opens reuse it.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'php',
    callback = function(args)
      local root = project.config_root(MARKERS, args.buf)
      if root and not M.analysed(root) then
        M.analyse { bufnr = args.buf }
      end
    end,
  })
end

return M
