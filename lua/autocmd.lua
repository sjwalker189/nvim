local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local BaseGroup = augroup('swalker', { clear = true })

-- Check if we need to reload the file when it changed
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = BaseGroup,
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd 'checktime'
    end
  end,
})

-- Highlight when yanking text
autocmd('TextYankPost', {
  group = augroup('highlight_yank', {}),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Close some filetypes with <q>
autocmd('FileType', {
  group = augroup('closeonq', {}),
  pattern = {
    'help',
    'lspinfo',
    'man',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- wrap and check for spell in text filetypes
autocmd('FileType', {
  group = BaseGroup,
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ 'BufWritePre' }, {
  group = BaseGroup,
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

autocmd('BufWritePost', {
  group = BaseGroup,
  pattern = '*.scm',
  callback = function()
    vim.cmd 'TSDisable highlight'
    vim.cmd 'TSEnable highlight'
    vim.notify 'Reloaded highlights'
  end,
})
