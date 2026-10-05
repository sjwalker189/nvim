return {
  src = {
    { src = 'https://github.com/stevearc/oil.nvim' },
  },
  setup = function()
    require('oil').setup {
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        -- <C-s> saves globally; in oil that write is what applies the edits.
        ['<C-s>'] = false,
        ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
      },
    }

    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    vim.keymap.set('n', '<leader>-', function()
      require('oil').toggle_float()
    end, { desc = 'Open parent directory in a float' })
  end,
}
