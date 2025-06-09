return {
  {
    'nvim-telescope/telescope.nvim',
    enabled = false,
    branch = '0.1.x',
    dependencies = {
      { 'kkharji/sqlite.lua' },
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-smart-history.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      local data = assert(vim.fn.stdpath 'data')

      require('telescope').setup {
        defaults = {
          preview = {
            -- Limit preview size to prevent freezing
            filesize_hook = function(filepath, bufnr, opts)
              local max_bytes = 10000
              local cmd = { 'head', '-c', max_bytes, filepath }
              require('telescope.previewers.utils').job_maker(cmd, bufnr, opts)
            end,
          },
          layout_config = {
            horizontal = { width = 0.9, height = 0.9 },
          },
        },
        extensions = {
          wrap_results = true,
          fzf = {},
          history = {
            path = vim.fs.joinpath(data, 'telescope_history.sqlite3'),
            limit = 100,
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      -- TODO: setup sqlite db properly
      -- pcall(require('telescope').load_extension, 'smart_history')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'

      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind [Word] under cursor' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope old files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>fm', builtin.man_pages, { desc = 'Telescope map pages' })
      vim.keymap.set('n', '<space>/', builtin.current_buffer_fuzzy_find)

      vim.keymap.set('n', '<leader>fc', function()
        builtin.find_files { cwd = '~/.config/nvim' }
      end, { desc = '[F]ind [C]onfiguration' })

      -- TODO: Look into LSP finders
      -- TODO: Look into GIT finders
    end,
  },
}
