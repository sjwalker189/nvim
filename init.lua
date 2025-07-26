local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Allow the sourcing of lua files from a non "nvim" directory, specifically to avoid commiting private code
package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/../nvim-lua/?.lua'

vim.g.mapleader = ' '

require('lazy').setup('plugins', {
  change_detection = { enabled = true, notify = false },
  checker = { enabled = false },
})

vim.cmd.runtime { 'lua/startup/*.lua', bang = true }
