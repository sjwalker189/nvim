vim.opt.rtp:prepend(vim.fn.stdpath 'data' .. '/site')

-- Allow the sourcing of lua files from a non "nvim" directory, specifically to avoid commiting private code
package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/../nvim-lua/?.lua'

-- [[ Settings ]]

vim.g.mapleader = ' '
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.opt.guicursor = ''
vim.opt.cursorline = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.showmode = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.formatoptions:remove 'o'
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.wo.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = 'menuone,noselect'
vim.opt.termguicolors = true
vim.opt.scrolloff = 20
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.laststatus = 3


-- [[ Keymaps ]]

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })
vim.keymap.set('n', '<C-s>', '<CMD>update<CR>', { desc = '[S]ave File' })
vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('n', '<C-Left>', '<C-w>h', { silent = true, noremap = true })
vim.keymap.set('n', '<C-Right>', '<C-w>l', { silent = true })
vim.keymap.set('n', '<C-Up>', '<C-w>k', { silent = true })
vim.keymap.set('n', '<C-Down>', '<C-w>j', { silent = true })
vim.keymap.set('n', '-', '<CMD>Ex<CR>', {})

-- [[ Diagnostics ]]

vim.diagnostic.config {
  underline = true,
  severity_sort = true,
  virtual_lines = false,
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
  },
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'if_many',
    header = '',
    prefix = '',
  },
}

-- [[ File Types ]]

vim.filetype.add {
  extension = {
    gloss = 'gloss',
    templ = 'templ',
  },
  pattern = {
    ['.*/test/corpus/.*%.txt'] = 'test',
  },
}

-- [[ Plugins ]]

require 'autocmd'
require 'plugins'
require('vim._core.ui2').enable()
