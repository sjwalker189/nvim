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

local mode = {
  n = 'n',
  v = 'v',
  i = 'i',
  x = 'x',
  all = { 'n', 'v', 'i', 'x' },
}

-- Connect keymaps when LSP servers attach to buffers
autocmd('LspAttach', {
  group = BaseGroup,
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set(mode.n, 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set(mode.n, 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set(mode.n, 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set(mode.n, '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set(mode.n, '<C-T>', vim.lsp.buf.type_definition, opts)
    vim.keymap.set(mode.n, '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set(mode.n, '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set(mode.all, '<C-.>', vim.lsp.buf.code_action, opts)
    vim.keymap.set(mode.all, '<F3>', vim.lsp.buf.code_action, opts)
    vim.keymap.set(mode.n, 'gr', vim.lsp.buf.references, opts)
  end,
})
