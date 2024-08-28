local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Allow the sourcing of lua files from a non "nvim" directory, specifically to avoid commiting private code
package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/../nvim-lua/?.lua'

vim.g.mapleader = ' '

require('lazy').setup('plugins', {
  change_detection = { enabled = false },
  checker = { enabled = false },
})

vim.cmd.runtime { 'lua/startup/*.lua', bang = true }
